require 'rails_helper'

RSpec.describe Adviser::SignUpAvailability do
  include_context 'get into teaching api stubbed endpoints'

  before do
    allow(Adviser::CandidateMatchback).to receive(:new).and_return(candidate_matchback_double)

    FeatureFlag.activate(:adviser_sign_up)

    allow(Rails).to receive(:cache).and_return(in_memory_store)
    Rails.cache.clear
  end

  let(:in_memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:application_form) { create(:completed_application_form, :with_domestic_adviser_qualifications) }
  let(:candidate_matchback_double) { instance_double(Adviser::CandidateMatchback, teacher_training_adviser_sign_up: Adviser::TeacherTrainingAdviserSignUpDecorator.new({})) }
  let(:constants) { Adviser::Constants }

  subject(:availability) { described_class.new(application_form) }

  shared_context 'availability precheck' do
    context 'when the feature is inactive' do
      before { FeatureFlag.deactivate(:adviser_sign_up) }

      it { expect(precheck_method_under_test).to be(false) }
    end

    context 'when the candidate cannot be retrieved because the GiT API is raising an error' do
      let(:error) { GetIntoTeachingApiClient::ApiError.new(code: 500) }

      before { allow(candidate_matchback_double).to receive(:teacher_training_adviser_sign_up).and_raise(error) }

      it { expect(precheck_method_under_test).to be(false) }

      it 'captures the exception' do
        allow(Sentry).to receive(:capture_exception)
        allow(Sentry).to receive(:capture_message)

        precheck_method_under_test

        expect(Sentry).to have_received(:capture_message)
        expect(Sentry).to have_received(:capture_exception).with(error)
      end
    end

    context 'when the candidate cannot be retrieved because other errors' do
      let(:error) { Faraday::Error.new('Some error') }

      before { allow(candidate_matchback_double).to receive(:teacher_training_adviser_sign_up).and_raise(error) }

      it { expect(precheck_method_under_test).to be(false) }

      it 'captures the exception' do
        allow(Sentry).to receive(:capture_exception)
        allow(Sentry).to receive(:capture_message)

        precheck_method_under_test

        expect(Sentry).to have_received(:capture_message)
        expect(Sentry).to have_received(:capture_exception).with(error)
      end
    end
  end

  describe '#available?' do
    let(:precheck_method_under_test) { availability.available? }

    include_context 'availability precheck'

    it { is_expected.to be_available }

    context 'when the application form is not applicable' do
      let(:application_form) { create(:application_form) }

      it { is_expected.not_to be_available }
    end
  end

  describe '#already_assigned_to_an_adviser?' do
    let(:precheck_method_under_test) { availability.already_assigned_to_an_adviser? }

    include_context 'availability precheck'

    it { is_expected.not_to be_already_assigned_to_an_adviser }

    it 'returns true when the adviser_status is assigned' do
      stub_matchback_with_adviser_status(:assigned)
      expect(availability).to be_already_assigned_to_an_adviser
    end

    it 'returns true when the adviser_status is previously_assigned' do
      stub_matchback_with_adviser_status(:previously_assigned)
      expect(availability).to be_already_assigned_to_an_adviser
    end
  end

  describe '#waiting_to_be_assigned_to_an_adviser?' do
    let(:precheck_method_under_test) { availability.waiting_to_be_assigned_to_an_adviser? }

    include_context 'availability precheck'

    it { is_expected.not_to be_waiting_to_be_assigned_to_an_adviser }

    it 'returns true when the adviser_status is waiting_to_be_assigned' do
      stub_matchback_with_adviser_status(:waiting_to_be_assigned)
      expect(availability).to be_waiting_to_be_assigned_to_an_adviser
    end
  end

  describe '#update_adviser_status' do
    let(:status) { ApplicationForm.adviser_statuses[:waiting_to_be_assigned] }

    it 'updates the application form' do
      expect { availability.update_adviser_status(status) }.to change(application_form, :adviser_status).to(status)
    end
  end

  describe 'refreshing the adviser status' do
    before { application_form.adviser_status = nil }

    subject(:check_availability) { availability.available? }

    it 'sets adviser_status to unassigned if the candidate is not found in the GiT API' do
      expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:unassigned])
    end

    context 'when the candidate is found in the GiT API' do
      let(:assignment_status_id) { constants.fetch(:adviser_status, :assigned) }

      before do
        api_model = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(
          assignment_status_id:,
        )

        allow(candidate_matchback_double).to receive(:teacher_training_adviser_sign_up) do
          @api_call_count = @api_call_count.to_i + 1
          Adviser::TeacherTrainingAdviserSignUpDecorator.new(api_model)
        end
      end

      context 'when the candidate has been assigned an adviser' do
        it { expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:assigned]) }
      end

      context 'when the candidate is waiting to be assigned an adviser' do
        let(:assignment_status_id) { constants.fetch(:adviser_status, :waiting_to_be_assigned) }

        it { expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:waiting_to_be_assigned]) }
      end

      context 'when the candidate has not been assigned an adviser' do
        let(:assignment_status_id) { constants.fetch(:adviser_status, :unassigned) }

        it { expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:unassigned]) }
      end

      context 'when the candidate has been previously assigned to an adviser' do
        let(:assignment_status_id) { constants.fetch(:adviser_status, :previously_assigned) }

        it { expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:previously_assigned]) }
      end

      it 'caches the response from the GiT API for 30 minutes' do
        availability.available?

        availability_2 = described_class.new(application_form)
        availability_2.available?

        TestSuiteTimeMachine.advance_time_by(31.minutes)

        availability_3 = described_class.new(application_form)
        availability_3.available?

        expect(@api_call_count).to eq(2)
      end
    end
  end

  def stub_matchback_with_adviser_status(status)
    assignment_status_id = constants.fetch(:adviser_status, status)
    matchback_candidate = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(assignment_status_id:)
    teacher_training_adviser_sign_up = Adviser::TeacherTrainingAdviserSignUpDecorator.new(matchback_candidate)
    allow(candidate_matchback_double).to receive(:teacher_training_adviser_sign_up) { teacher_training_adviser_sign_up }
  end
end

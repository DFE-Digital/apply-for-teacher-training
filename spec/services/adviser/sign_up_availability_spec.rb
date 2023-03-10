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
  let(:candidate_matchback_double) { instance_double(Adviser::CandidateMatchback, matchback: nil) }

  subject(:availability) { described_class.new(application_form) }

  describe '#available?' do
    it { is_expected.to be_available }

    context 'when the feature is inactive' do
      before { FeatureFlag.deactivate(:adviser_sign_up) }

      it { is_expected.not_to be_available }
    end

    context 'when the application form is not applicable' do
      let(:application_form) { create(:application_form) }

      it { is_expected.not_to be_available }
    end

    context 'when the candidate cannot be retrieved because the GiT API is raising an error' do
      let(:error) { GetIntoTeachingApiClient::ApiError.new(code: 500) }

      before { allow(candidate_matchback_double).to receive(:matchback).and_raise(error) }

      it { is_expected.not_to be_available }

      it 'captures the exception' do
        allow(Sentry).to receive(:capture_exception)

        availability.available?

        expect(Sentry).to have_received(:capture_exception).with(error)
      end
    end
  end

  describe '#update_adviser_status' do
    it 'updates the application form adviser_status' do
      new_status = ApplicationForm.adviser_statuses[:assigned]
      expect { availability.update_adviser_status(new_status) }
        .to change(application_form, :adviser_status).to(new_status)
    end

    it 'overwrites the cached adviser status' do
      expect(availability).to be_available
      availability.update_adviser_status(ApplicationForm.adviser_statuses[:waiting_to_be_assigned])
      expect(availability).not_to be_available
    end
  end

  describe 'refreshing the adviser status' do
    before { application_form.adviser_status = nil }

    subject(:check_availability) { availability.available? }

    it 'sets adviser_status to unassigned if the candidate is not found in the GiT API' do
      expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:unassigned])
    end

    context 'when the candidate is found in the GiT API' do
      let(:adviser_status_id) { described_class::ADVISER_STATUS.key(ApplicationForm.adviser_statuses[:assigned]) }

      before do
        api_model = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(
          adviser_status_id:,
        )

        allow(candidate_matchback_double).to receive(:matchback) do
          @api_call_count = @api_call_count.to_i + 1
          Adviser::APIModelDecorator.new(api_model)
        end
      end

      context 'when the candidate has been assigned an adviser' do
        it { expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:assigned]) }
      end

      context 'when the candidate is waiting to be assigned an adviser' do
        let(:adviser_status_id) { described_class::ADVISER_STATUS.key(ApplicationForm.adviser_statuses[:waiting_to_be_assigned]) }

        it { expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:waiting_to_be_assigned]) }
      end

      context 'when the candidate has not been assigned an adviser' do
        let(:adviser_status_id) { described_class::ADVISER_STATUS.key(ApplicationForm.adviser_statuses[:unassigned]) }

        it { expect { check_availability }.to change(application_form, :adviser_status).to(ApplicationForm.adviser_statuses[:unassigned]) }
      end

      context 'when the candidate has been previously assigned to an adviser' do
        let(:adviser_status_id) { described_class::ADVISER_STATUS.key(ApplicationForm.adviser_statuses[:previously_assigned]) }

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
end

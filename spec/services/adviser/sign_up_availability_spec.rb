require 'rails_helper'

RSpec.describe Adviser::SignUpAvailability do
  include_context 'get into teaching api stubbed endpoints'
  include_context 'get into teaching api stubbed unsuccessful matchback'

  before do
    FeatureFlag.activate(:adviser_sign_up)

    allow(Rails).to receive(:cache).and_return(in_memory_store)
    Rails.cache.clear
  end

  let(:in_memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:application_form) { create(:completed_application_form, :with_domestic_adviser_qualifications) }

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

    context 'when the Get into Teaching API is unavailable' do
      before do
        error = GetIntoTeachingApiClient::ApiError.new(code: 500)
        allow_any_instance_of(GetIntoTeachingApiClient::TeacherTrainingAdviserApi)
          .to receive(:matchback_candidate).and_raise(error)
      end

      it { is_expected.not_to be_available }

      it 'logs a warning' do
        allow(Rails.logger).to receive(:warn)

        availability.available?

        expect(Rails.logger).to have_received(:warn).with(/sign up unavailable/)
      end
    end
  end

  describe 'updating the adviser status' do
    subject(:check_availability) { availability.available? }

    it 'does not change signed_up_for_adviser if the candidate is not found in the GiT API' do
      expect { check_availability }.not_to change(application_form, :signed_up_for_adviser)
    end

    context 'when the candidate is found in the GiT API and has not yet signed up for an adviser' do
      before do
        api_response = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(
          can_subscribe_to_teacher_training_adviser: true,
        )

        allow_any_instance_of(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to \
          receive(:matchback_candidate).with(existing_candidate_request) do
            @api_call_count = @api_call_count.to_i + 1
            api_response
          end
      end

      it 'does not change the adviser status' do
        expect { check_availability }.not_to change(application_form, :signed_up_for_adviser)
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

    it 'sets signed_up_for_adviser to true if the candidate is found in the GiT API and has already signed up for an adviser' do
      api_response = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(
        can_subscribe_to_teacher_training_adviser: false,
      )

      allow_any_instance_of(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).to \
        receive(:matchback_candidate).with(existing_candidate_request) { api_response }

      expect { check_availability }.to change(application_form, :signed_up_for_adviser).from(false).to(true)
    end

    it 'does not make a request to the GiT API if we know that the candidate has already signed up for an adviser' do
      expect_any_instance_of(GetIntoTeachingApiClient::TeacherTrainingAdviserApi).not_to \
        receive(:matchback_candidate)

      application_form.signed_up_for_adviser = true

      check_availability
    end
  end
end

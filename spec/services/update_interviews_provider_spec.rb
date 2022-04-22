require 'rails_helper'

RSpec.describe UpdateInterviewsProvider do
  include CourseOptionHelpers

  let(:application_choice) { create(:application_choice, status: :interviewing, interviews: [interview], course_option: course_option, current_course_option: course_option) }
  let(:interview) { create(:interview, provider: old_training_provider) }
  let(:another_interview) { create(:interview, provider: old_training_provider) }
  let(:cancelled_interview) { create(:interview, :future_date_and_time, :cancelled, provider: old_training_provider) }
  let(:application_choice_with_multiple_interviews) { create(:application_choice, status: :interviewing, interviews: [interview, another_interview, cancelled_interview], course_option: course_option) }
  let(:course_option) { course_option_for_accredited_provider(provider: new_training_provider, accredited_provider: accredited_provider) }
  let(:old_training_provider) { create(:provider) }
  let(:new_training_provider) { create(:provider) }
  let(:accredited_provider) { create(:provider) }

  let(:provider_user) { create(:provider_user, :with_set_up_interviews, providers: [old_training_provider, new_training_provider, accredited_provider]) }

  let(:old_provider_params) do
    {
      actor: provider_user,
      provider: old_training_provider,
      application_choice: application_choice,
    }
  end

  let(:new_provider_params) do
    {
      actor: provider_user,
      provider: new_training_provider,
      application_choice: application_choice,
    }
  end

  before do
    mailer = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
    allow(CandidateMailer).to receive(:interview_updated).and_return(mailer)
  end

  describe '#save!' do
    context 'when it is a valid provider' do
      it 'updates the existing interview with provided params' do
        described_class.new(new_provider_params).save!

        expect(interview.reload.provider).to eq(new_training_provider)
      end

      it 'touches the application choice' do
        expect {
          described_class.new(new_provider_params).save!
        }.to change(application_choice, :updated_at)
      end

      it 'sends an email' do
        described_class.new(new_provider_params).notify

        expect(CandidateMailer).to have_received(:interview_updated).with(application_choice, interview)
      end
    end

    context 'when the provider is the same' do
      it 'does not update the existing interview with provided params' do
        expect {
          described_class.new(old_provider_params).save!
        }.not_to change(interview, :provider_id)
      end

      it 'does not touch the application choice' do
        expect {
          described_class.new(old_provider_params).save!
        }.not_to change(application_choice, :updated_at)
      end

      it 'does not send an email' do
        described_class.new(old_provider_params).notify

        expect(CandidateMailer).not_to have_received(:interview_updated).with(application_choice, interview)
      end
    end

    context 'when the interview is set to the accredited provider' do
      let(:interview) { create(:interview, provider: accredited_provider) }

      it 'does not update the existing interview with provided params' do
        expect {
          described_class.new(new_provider_params).save!
        }.not_to change(interview, :provider_id)
      end

      it 'does not touch the application choice' do
        expect {
          described_class.new(new_provider_params).save!
        }.not_to change(application_choice, :updated_at)
      end

      it 'does not send an email' do
        described_class.new(new_provider_params).notify

        expect(CandidateMailer).not_to have_received(:interview_updated).with(application_choice, interview)
      end
    end

    context 'when the provider is the same as the accredited provider' do
      let(:course_option) { course_option_for_accredited_provider(provider: accredited_provider, accredited_provider: accredited_provider) }
      let(:service_params) do
        {
          actor: provider_user,
          provider: accredited_provider,
          application_choice: application_choice,
        }
      end

      it 'updates the existing interview with provided params' do
        described_class.new(service_params).save!

        expect(interview.reload.provider).to eq(accredited_provider)
      end

      it 'touches the application choice' do
        expect {
          described_class.new(service_params).save!
        }.to change(application_choice, :updated_at)
      end

      it 'sends an email' do
        described_class.new(service_params).notify

        expect(CandidateMailer).to have_received(:interview_updated).with(application_choice, interview)
      end
    end

    context 'when there are multiple interviews' do
      let(:service_params) do
        {
          actor: provider_user,
          provider: new_training_provider,
          application_choice: application_choice_with_multiple_interviews,
        }
      end

      it 'updates all the existing interviews with provided params' do
        described_class.new(service_params).save!

        expect(interview.reload.provider_id).to eq(new_training_provider.id)
        expect(another_interview.reload.provider_id).to eq(new_training_provider.id)
        expect(cancelled_interview.reload.provider_id).to eq(old_training_provider.id)
      end
    end

    context 'when an interview is in the past' do
      let(:interview) { create(:interview, :past_date_and_time, provider: old_training_provider) }

      it 'does not update the existing interview with provided params' do
        expect {
          described_class.new(old_provider_params).save!
        }.not_to change(interview, :provider_id)
      end

      it 'does not touch the application choice' do
        expect {
          described_class.new(old_provider_params).save!
        }.not_to change(application_choice, :updated_at)
      end

      it 'does not send an email' do
        described_class.new(old_provider_params).notify

        expect(CandidateMailer).not_to have_received(:interview_updated).with(application_choice, interview)
      end
    end

    context 'when an interview has been cancelled' do
      let(:interview) { create(:interview, :cancelled, provider: old_training_provider) }

      it 'does not update the existing interview with provided params' do
        expect {
          described_class.new(old_provider_params).save!
        }.not_to change(interview, :provider_id)
      end

      it 'does not touch the application choice' do
        expect {
          described_class.new(old_provider_params).save!
        }.not_to change(application_choice, :updated_at)
      end

      it 'does not send an email' do
        described_class.new(old_provider_params).notify

        expect(CandidateMailer).not_to have_received(:interview_updated).with(application_choice, interview)
      end
    end

    context 'when an application has been rejected' do
      let(:application_choice) { create(:application_choice, status: :rejected, interviews: [interview], current_course_option: course_option) }

      it 'raises a validation error' do
        expect { described_class.new(new_provider_params).save! }.to raise_error(InterviewWorkflowConstraints::WorkflowError)
      end
    end

    context 'when the provider is not valid' do
      let(:different_provider) { create(:provider) }
      let(:service_params) do
        {
          actor: provider_user,
          provider: different_provider,
          application_choice: application_choice,
        }
      end

      it 'raises a validation error' do
        expect { described_class.new(service_params).save! }.to raise_error(ValidationException)
      end
    end
  end
end

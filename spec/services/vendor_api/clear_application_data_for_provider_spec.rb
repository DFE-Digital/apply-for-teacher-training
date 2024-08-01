require 'rails_helper'

RSpec.describe VendorAPI::ClearApplicationDataForProvider do
  include CourseOptionHelpers

  describe '.call' do
    let(:provider) { create(:provider) }

    it 'deletes a candidate if the course on their application is associated to the provider' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_provider(provider:),
      )

      expect { described_class.call(provider) }.to change { Candidate.count }.from(1).to(0)
    end

    it 'deletes a candidate if the course on an application is associated to the accredited provider' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_accredited_provider(
          accredited_provider: provider,
          provider: create(:provider),
        ),
      )

      expect { described_class.call(provider) }.to change { Candidate.count }.from(1).to(0)
    end

    it 'deletes all associated application choices to the candidate' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_provider(provider:),
      )

      expect { described_class.call(provider) }.to change { ApplicationChoice.count }.from(1).to(0)
    end

    it 'deletes all associated offers to the candidate' do
      create(
        :application_choice,
        :offered,
        course_option: course_option_for_provider(provider:),
      )

      expect { described_class.call(provider) }.to change { Offer.count }.from(1).to(0)
    end

    it 'deletes all associated offer conditions to the candidate' do
      create(
        :application_choice,
        :offered,
        course_option: course_option_for_provider(provider:),
      )

      expect { described_class.call(provider) }.to change { OfferCondition.count }.from(1).to(0)
    end

    it 'deletes all associated application forms to the candidate' do
      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_provider(provider:),
      )

      expect { described_class.call(provider) }.to change { ApplicationForm.count }.from(1).to(0)
    end

    it 'deletes all emails and email clicks associated with the application forms' do
      email_click = create(:email_click)

      create(
        :application_choice,
        :awaiting_provider_decision,
        course_option: course_option_for_provider(provider:),
        application_form: email_click.email.application_form,
      )

      expect { described_class.call(provider) }.to change { Email.count }.from(1).to(0)
        .and(change { EmailClick.count }.from(1).to(0))
    end

    it 'deletes applications choices with rejection feedback' do
      create(
        :rejection_feedback,
        application_choice: create(
          :application_choice,
          :rejected,
          course_option: course_option_for_provider(provider:),
        ),
      )

      expect { described_class.call(provider) }.to change { RejectionFeedback.count }.from(1).to(0)
    end

    it 'does not work in production' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
        expect { described_class.call(provider) }.to raise_error('This is not meant to be run in production')
      end
    end
  end
end

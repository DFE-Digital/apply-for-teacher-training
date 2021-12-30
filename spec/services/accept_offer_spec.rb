require 'rails_helper'

RSpec.describe AcceptOffer do
  include CourseOptionHelpers

  it 'sets the accepted_at date for the application_choice' do
    application_choice = create(:application_choice, :with_offer)

    Timecop.freeze do
      expect {
        described_class.new(application_choice: application_choice).save!
      }.to change { application_choice.accepted_at }.to(Time.zone.now)
    end
  end

  it 'calls AcceptUnconditionalOffer when the feature is enabled and the offer is unconditional' do
    FeatureFlag.activate(:unconditional_offers_via_api)

    application_choice = create(:application_choice,
                                :with_offer,
                                offer: build(:unconditional_offer))
    allow(AcceptUnconditionalOffer).to receive(:new).and_call_original

    described_class.new(application_choice: application_choice).save!

    expect(AcceptUnconditionalOffer).to have_received(:new).with(application_choice: application_choice)
  end

  describe 'other choices in the application' do
    it 'with offers are declined' do
      application_choice = create(:application_choice, :with_offer)
      application_form = application_choice.application_form
      other_choice_with_offer = create(:application_choice, :with_offer, application_form: application_form)

      described_class.new(application_choice: application_choice).save!

      expect(other_choice_with_offer.reload.status).to eq('declined')
    end

    it 'that are pending provider decisions are withdrawn' do
      application_choice = create(:application_choice, :with_offer)
      application_form = application_choice.application_form
      other_choice_awaiting_decision = create(:application_choice, :awaiting_provider_decision, application_form: application_form)
      other_choice_interviewing = create(:application_choice, :with_scheduled_interview, application_form: application_form)

      described_class.new(application_choice: application_choice).save!

      expect(other_choice_awaiting_decision.reload.status).to eq('withdrawn')
      expect(other_choice_interviewing.reload.status).to eq('withdrawn')
    end
  end

  describe 'emails', sidekiq: true do
    it 'sends a notification email to the training provider and ratifying provider' do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_choice = create(:application_choice, :with_offer, course_option: course_option)

      expect { described_class.new(application_choice: application_choice).save! }.to change { ActionMailer::Base.deliveries.count }.by(3)

      emails_to_providers = ActionMailer::Base.deliveries.take(2) # email 3 goes to candidate

      expect(emails_to_providers.map(&:subject)).to all(match(/accepted your offer for #{course_option.course.name}/))
      expect(emails_to_providers.flat_map(&:to)).to match_array([training_provider_user.email_address, ratifying_provider_user.email_address])
    end

    it 'sends a confirmation email to the candidate' do
      application_choice = create(:application_choice, :with_offer)

      expect { described_class.new(application_choice: application_choice).save! }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.candidate.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/You’ve accepted/)
    end
  end
end

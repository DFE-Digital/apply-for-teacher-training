require 'rails_helper'

RSpec.describe AcceptUnconditionalOffer do
  include CourseOptionHelpers

  it 'sets the accepted_at and recruited_at dates for the application_choice' do
    application_choice = build(:application_choice, status: :offer)

    expect {
      described_class.new(application_choice:).save!
    }.to change { application_choice.accepted_at }.to(Time.zone.now)
    .and change { application_choice.recruited_at }.to(Time.zone.now)
  end

  it 'returns false on state transition errors' do
    state_change_double = instance_double(ApplicationStateChange)
    allow(state_change_double).to receive(:accept_unconditional_offer!).and_raise(Workflow::NoTransitionAllowed)
    allow(ApplicationStateChange).to receive(:new).and_return(state_change_double)

    expect(described_class.new(application_choice: build(:application_choice)).save!).to be false
    expect(state_change_double).to have_received(:accept_unconditional_offer!)
  end

  describe 'other choices in the application' do
    it 'declines offered applications' do
      application_choice = create(:application_choice, :offered)
      application_form = application_choice.application_form
      other_choice_with_offer = create(:application_choice, :offered, application_form:)

      described_class.new(application_choice:).save!

      expect(other_choice_with_offer.reload.status).to eq('declined')
    end

    it 'withdraws applications pending provider decisions' do
      application_choice = create(:application_choice, :offered)
      application_form = application_choice.application_form
      other_choice_awaiting_decision = create(:application_choice, :awaiting_provider_decision, application_form:)
      other_choice_interviewing = create(:application_choice, :interviewing, application_form:)

      described_class.new(application_choice:).save!

      expect(other_choice_awaiting_decision.reload.status).to eq('withdrawn')
      expect(other_choice_interviewing.reload.status).to eq('withdrawn')
    end
  end

  describe 'emails' do
    around { |example| perform_enqueued_jobs(&example) }

    it 'sends a notification email to the training provider and ratifying provider' do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_choice = build(:application_choice, :offered, course_option:)

      expect { described_class.new(application_choice:).save! }.to change { ActionMailer::Base.deliveries.count }.by(3)
      expect(ActionMailer::Base.deliveries.first.subject).to match(/accepted your offer for #{Regexp.escape(application_choice.course.name)}/)

      mailer_recipients = ActionMailer::Base.deliveries.map(&:to).flatten
      expect(mailer_recipients).to include(training_provider_user.email_address)
      expect(mailer_recipients).to include(ratifying_provider_user.email_address)
    end

    it 'sends a confirmation email to the candidate' do
      application_choice = create(:application_choice, status: :offer)

      expect { described_class.new(application_choice:).save! }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.candidate.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/You have accepted/)
    end

    it 'sends an email to the candidates referees' do
      application_form = create(:application_form, application_references: [create(:reference, :not_requested_yet), create(:reference, :not_requested_yet)])
      application_choice = create(:application_choice, status: :offer, application_form: application_form)

      expect { described_class.new(application_choice:).save! }.to change { ActionMailer::Base.deliveries.count }.by(3)
      expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.application_references.creation_order.first.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/ Teacher training reference needed for /)
    end
  end
end

require 'rails_helper'

RSpec.describe AcceptOffer do
  include CourseOptionHelpers

  before do
    TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_opens(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR))
  end

  describe '#valid?' do
    context 'when valid references' do
      it 'returns true' do
        application_form = create(:completed_application_form, :with_completed_references)
        application_choice = create(:application_choice, :offered, application_form:)

        expect(described_class.new(application_choice:)).to be_valid
      end
    end

    context 'when invalid references' do
      it 'returns false' do
        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        application_choice = create(:application_choice, :offered, application_form:)
        application_form.application_references.each(&:destroy)

        expect(described_class.new(application_choice:)).not_to be_valid
      end
    end

    context 'when one of the references has incomplete email' do
      it 'is invalid' do
        application_form = create(:application_form, :minimum_info, recruitment_cycle_year: 2023)
        application_choice = create(:application_choice, :offered, application_form: application_form)
        create(:reference, application_form: application_form)
        create(:reference, email_address: nil, application_form: application_form)
        form = described_class.new(application_choice: application_choice)
        expect(form).not_to be_valid
        expect(form.errors[:application_choice]).to include(
          I18n.t('errors.messages.incomplete_references'),
        )
      end
    end

    context 'when the reference is pending', :sidekiq do
      it 'send the reference request' do
        application_form = create(:completed_application_form, :with_completed_references, recruitment_cycle_year: 2023)
        application_choice = create(:application_choice, :offered, application_form:)
        pending_reference = create(:reference, :not_requested_yet, application_form:)

        described_class.new(application_choice:).save!

        expect(pending_reference.reload.feedback_status).to eq('feedback_requested')
        expect(ActionMailer::Base.deliveries.first.to).to eq [pending_reference.email_address]
      end
    end

    context 'when the reference has already been received', :sidekiq do
      it 'does not send the reference request' do
        application_form = create(:completed_application_form, :with_completed_references, recruitment_cycle_year: 2023)
        application_choice = create(:application_choice, :offered, application_form:)
        received_reference = create(:reference, :feedback_provided, application_form:)

        described_class.new(application_choice:).save!

        expect(received_reference.reload.feedback_status).to eq('feedback_provided')
        expect(ActionMailer::Base.deliveries.first.to).not_to eq [received_reference.email_address]
      end
    end
  end

  it 'sets the accepted_at date for the application_choice' do
    application_choice = create(:application_choice, :offered)

    expect {
      described_class.new(application_choice:).save!
    }.to change { application_choice.accepted_at }.to(Time.zone.now)
  end

  it 'calls AcceptUnconditionalOffer when the feature is enabled and the offer is unconditional' do
    FeatureFlag.activate(:unconditional_offers_via_api)

    application_choice = create(:application_choice,
                                :offered,
                                offer: build(:unconditional_offer))
    allow(AcceptUnconditionalOffer).to receive(:new).and_call_original

    described_class.new(application_choice:).save!

    expect(AcceptUnconditionalOffer).to have_received(:new).with(application_choice:)
  end

  describe 'status changes on sibling choices' do
    let(:application_form) { application_choice.application_form }
    let(:application_choice) { create(:application_choice, :offered) }

    it 'changes decision_pending statuses to withdrawn' do
      awaiting_provider_decision = create(:application_choice, :awaiting_provider_decision, application_form:)
      interviewing = create(:application_choice, :interviewing, application_form:)
      inactive = create(:application_choice, :inactive, application_form:)

      described_class.new(application_choice:).save!
      expect(awaiting_provider_decision.reload.status).to eq('withdrawn')
      expect(interviewing.reload.status).to eq('withdrawn')
      expect(inactive.reload.status).to eq('withdrawn')
    end

    it 'does not change the status of unsubmitted, deferred, pending_conditions' do
      deferred = create(:application_choice, :offer_deferred, application_form:)
      unsubmitted = create(:application_choice, :unsubmitted, application_form:)
      pending_conditions = create(:application_choice, :pending_conditions, application_form:)

      described_class.new(application_choice:).save!
      expect(deferred.reload.status).to eq('offer_deferred')
      expect(unsubmitted.reload.status).to eq('unsubmitted')
      expect(pending_conditions.reload.status).to eq('pending_conditions')
    end

    it 'does not change the status of application_not_sent or recruited' do
      application_not_sent = create(:application_choice, :application_not_sent, application_form:)
      recruited = create(:application_choice, :recruited, application_form:)

      described_class.new(application_choice:).save!
      expect(application_not_sent.reload.status).to eq('application_not_sent')
      expect(recruited.reload.status).to eq('recruited')
    end

    it 'does not change the status of offer_withdrawn or withdrawn' do
      offer_withdrawn = create(:application_choice, :offer_withdrawn, application_form:)
      withdrawn = create(:application_choice, :withdrawn, application_form:)

      described_class.new(application_choice:).save!
      expect(offer_withdrawn.reload.status).to eq('offer_withdrawn')
      expect(withdrawn.reload.status).to eq('withdrawn')
    end

    it 'changes "offer" status to "declined"' do
      offered = create(:application_choice, :offered, application_form:)

      expect {
        described_class.new(application_choice:).save!
      }.to change { offered.reload.status }.from('offer').to('declined')
    end
  end

  describe 'emails', :sidekiq do
    it 'sends a notification email to the training provider and ratifying provider' do
      training_provider = create(:provider)
      training_provider_user = create(:provider_user, :with_notifications_enabled, providers: [training_provider])

      ratifying_provider = create(:provider)
      ratifying_provider_user = create(:provider_user, :with_notifications_enabled, providers: [ratifying_provider])

      course_option = course_option_for_accredited_provider(provider: training_provider, accredited_provider: ratifying_provider)
      application_choice = create(:application_choice, :offered, course_option:)

      expect { described_class.new(application_choice:).save! }.to change { ActionMailer::Base.deliveries.count }.by(3)

      emails_to_providers = ActionMailer::Base.deliveries.take(2) # email 3 goes to candidate

      expect(emails_to_providers.map(&:subject)).to all(match(/accepted your offer for #{Regexp.escape(course_option.course.name)}/))
      expect(emails_to_providers.flat_map(&:to)).to contain_exactly(training_provider_user.email_address, ratifying_provider_user.email_address)
    end

    it 'sends a confirmation email to the candidate' do
      application_choice = create(:application_choice, :offered)

      expect { described_class.new(application_choice:).save! }.to change { ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.to).to eq [application_choice.application_form.candidate.email_address]
      expect(ActionMailer::Base.deliveries.first.subject).to match(/You’ve accepted/)
    end
  end
end

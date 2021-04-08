require 'rails_helper'

RSpec.describe SupportInterface::CandidateJourneyTracker, with_audited: true do
  let!(:now) { Time.zone.now.change(usec: 0) }

  around do |example|
    Timecop.freeze(now) { example.run }
  end

  describe '#form_not_started' do
    it 'returns time when the application was created' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).form_not_started).to eq now
    end
  end

  describe '#form_started_but_unsubmitted' do
    it 'returns the time when the application choice was created if the audit trail is empty' do
      application_form = create(:application_form, created_at: 5.days.ago)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq application_choice.created_at
    end

    it 'returns the time when the application form was first updated if this is recorded in the audit trail', audited: true do
      application_form = create(:application_form, created_at: 5.days.ago)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)
      application_form.update(phone_number: '01234 567890')

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq now
    end

    it 'returns the time when the application choice was created if this is earlier than any audit trail updated entries', audited: true do
      application_form = create(:application_form, created_at: 5.days.ago)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form, created_at: 1.day.ago)
      application_form.update(phone_number: '01234 567890')

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq application_choice.created_at
    end
  end

  describe '#submitted' do
    it 'returns the time when the application form was submitted' do
      submitted_at = 5.days.ago
      application_form = create(:application_form, submitted_at: submitted_at)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).submitted_at).to eq submitted_at
    end

    it 'returns nil if the application form has not been submitted' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).submitted_at).to be_nil
    end
  end

  describe 'completed references' do
    let!(:application_form) do
      create(:completed_application_form, application_choices_count: 1)
    end
    let(:application_choice) { application_form.application_choices.first }
    let(:reference_1) { build(:reference, :feedback_provided, requested_at: 4.days.ago - 1.hour, feedback_provided_at: 1.day.ago) }
    let(:reference_2) { build(:reference, :feedback_provided, requested_at: 4.days.ago - 2.hours, feedback_provided_at: 2.days.ago) }
    # Historically, applications may have more than 2 completed references:
    let(:reference_3) { build(:reference, :feedback_provided, requested_at: 4.days.ago - 3.hours, feedback_provided_at: 3.days.ago) }

    describe '#completed_reference_1_requested_at' do
      it 'returns nil if no references have been requested' do
        expect(described_class.new(application_choice).completed_reference_1_requested_at).to be_nil
      end

      it 'returns the time when the first completed reference was requested' do
        application_form.application_references = [reference_1, reference_2, reference_3]
        expect(described_class.new(application_choice).completed_reference_1_requested_at).to eq(reference_3.requested_at)
      end
    end

    describe '#completed_reference_2_requested_at' do
      it 'returns nil if no references have been requested' do
        expect(described_class.new(application_choice).completed_reference_2_requested_at).to be_nil
      end

      it 'returns nil if one reference has been requested' do
        application_form.application_references = [reference_1]
        expect(described_class.new(application_choice).completed_reference_2_requested_at).to be_nil
      end

      it 'returns the time when the second completed reference was requested' do
        application_form.application_references = [reference_1, reference_2, reference_3]
        expect(described_class.new(application_choice).completed_reference_2_requested_at).to eq(reference_2.requested_at)
      end
    end

    describe '#completed_reference_1_received_at' do
      it 'returns nil if no references were received' do
        expect(described_class.new(application_choice).completed_reference_1_received_at).to be_nil
      end

      it 'returns the time when the first reference was received' do
        application_form.application_references = [reference_1, reference_2, reference_3]
        expect(described_class.new(application_choice).completed_reference_1_received_at).to eq(reference_3.feedback_provided_at)
      end
    end

    describe '#completed_reference_2_received_at' do
      it 'returns nil if only one reference has been received' do
        application_form.application_references = [reference_1]
        expect(described_class.new(application_choice).completed_reference_2_received_at).to be_nil
      end

      it 'returns the time when the second reference was received' do
        application_form.application_references = [reference_1, reference_2, reference_3]
        expect(described_class.new(application_choice).completed_reference_2_received_at).to eq(reference_2.feedback_provided_at)
      end
    end

    context 'when missing a feedback_provided_at timestamp' do
      # A scenario that can occur due to historic bugs causing incomplete data
      it 'returns no reference data' do
        application_form.application_references = [reference_1, reference_2, reference_3]
        reference_2.update!(feedback_provided_at: nil)

        expect(described_class.new(application_choice).completed_reference_1_requested_at).to eq(nil)
        expect(described_class.new(application_choice).completed_reference_2_requested_at).to eq(nil)
        expect(described_class.new(application_choice).completed_reference_1_received_at).to eq(nil)
        expect(described_class.new(application_choice).completed_reference_2_received_at).to eq(nil)
      end
    end

    describe '#received_references' do
      it 'returns only references related to the application choice' do
        create(:reference, :feedback_provided, requested_at: 4.days.ago, feedback_provided_at: 3.days.ago)
        application_form.application_references = [reference_1, reference_2, reference_3]

        expect(described_class.new(application_choice).received_references).to eq([reference_3, reference_2, reference_1])
      end
    end
  end

  describe '#reference_reminder_email_sent' do
    it 'returns nil if no chasers were sent' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).reference_reminder_email_sent).to be_nil
    end

    it 'returns time of the earliest chaser sent' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)
      application_reference1 = create(:reference, :feedback_requested, application_form: application_form)
      application_reference2 = create(:reference, :feedback_requested, application_form: application_form)
      Timecop.freeze(now + 1.day) do
        ChaserSent.create!(chased: application_reference1, chaser_type: :reference_request)
      end
      Timecop.freeze(now + 2.days) do
        ChaserSent.create!(chased: application_reference2, chaser_type: :reference_request)
      end

      expect(described_class.new(application_choice).reference_reminder_email_sent).to eq(now + 1.day)
    end
  end

  describe '#new_reference_request_email_sent' do
    it 'returns nil if no chasers were sent' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).new_reference_request_email_sent).to be_nil
    end

    it 'returns time of the earliest chaser sent' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)
      create(:reference, :feedback_requested, application_form: application_form)
      application_reference2 = create(:reference, :feedback_refused, application_form: application_form)
      Timecop.freeze(now + 1.day) do
        ChaserSent.create!(chased: application_reference2, chaser_type: :reference_replacement)
      end

      expect(described_class.new(application_choice).new_reference_request_email_sent).to eq(now + 1.day)
    end
  end

  describe '#new_reference_added' do
    it 'returns nil when there are only two references' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)
      create(:reference, :feedback_requested, application_form: application_form)
      create(:reference, :feedback_requested, application_form: application_form)

      expect(described_class.new(application_choice).new_reference_added).to be_nil
    end

    it 'returns time of the earliest chaser sent' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)
      create(:reference, :feedback_requested, application_form: application_form)
      create(:reference, :feedback_refused, application_form: application_form)

      Timecop.freeze(now + 1.day) do
        create(:reference, :feedback_requested, application_form: application_form)
      end

      expect(described_class.new(application_choice).new_reference_added).to eq(now + 1.day)
    end
  end

  describe '#rbd_date' do
    it 'returns the correct timestamp' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :awaiting_provider_decision,
        reject_by_default_at: now + 40.days,
        application_form: application_form,
      )

      expect(described_class.new(application_choice).rbd_date).to eq(now + 40.days)
    end
  end

  describe '#rbd_reminder_sent' do
    it 'returns nil when no chaser has been sent' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :awaiting_provider_decision,
        application_form: application_form,
      )

      expect(described_class.new(application_choice).rbd_reminder_sent).to be_nil
    end

    it 'returns the time when the chaser was sent' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :awaiting_provider_decision,
        application_form: application_form,
      )

      Timecop.freeze(now + 1.day) do
        ChaserSent.create!(chased: application_choice, chaser_type: :provider_decision_request)
      end

      expect(described_class.new(application_choice).rbd_reminder_sent).to eq(now + 1.day)
    end
  end

  describe '#application_rbd' do
    it 'returns nil if the application was explicitly rejected' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :awaiting_provider_decision,
        application_form: application_form,
      )

      Timecop.freeze(now + 1.day) do
        application_choice.update(rejected_at: now + 1.day)
      end

      expect(described_class.new(application_choice).application_rbd).to be_nil
    end

    it 'returns rejected_at if the application was rejected by default' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :awaiting_provider_decision,
        application_form: application_form,
      )

      Timecop.freeze(now + 1.day) do
        application_choice.update(rejected_at: now + 1.day, rejected_by_default: true)
      end

      expect(described_class.new(application_choice).application_rbd).to eq(now + 1.day)
    end
  end

  describe '#provider_decision' do
    it 'returns nil if application has never been offered or rejected' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)

      expect(described_class.new(application_choice).provider_decision).to be_nil
    end

    it 'returns time when offer was made' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)
      application_choice.update(status: :offer, offered_at: now + 5.days)

      expect(described_class.new(application_choice).provider_decision).to eq(now + 5.days)
    end

    it 'returns time when application was rejected' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)
      application_choice.update(status: :rejected, rejected_at: now + 5.days)

      expect(described_class.new(application_choice).provider_decision).to eq(now + 5.days)
    end
  end

  describe '#offer_made' do
    it 'returns nil if application has never been offered' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)

      expect(described_class.new(application_choice).offer_made).to be_nil
    end

    it 'returns time when offer was made' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)
      application_choice.update(status: :offer, offered_at: now + 5.days)

      expect(described_class.new(application_choice).offer_made).to eq(now + 5.days)
    end
  end

  describe '#candidate_decision' do
    it 'returns nil if application has never been accepted or declined' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :offer, application_form: application_form)

      expect(described_class.new(application_choice).candidate_decision).to be_nil
    end

    it 'returns time when offer was declined' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :offer, application_form: application_form)
      application_choice.update(status: :declined, declined_at: now + 5.days)

      expect(described_class.new(application_choice).candidate_decision).to eq(now + 5.days)
    end

    it 'returns time when offer was accepted' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :offer, application_form: application_form)
      application_choice.update(status: :pending_conditions, accepted_at: now + 5.days)

      expect(described_class.new(application_choice).candidate_decision).to eq(now + 5.days)
    end
  end

  describe '#offer_declined' do
    it 'returns nil if application has never been declined' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :offer, application_form: application_form)

      expect(described_class.new(application_choice).offer_declined).to be_nil
    end

    it 'returns time when offer was declined' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :offer, application_form: application_form)
      application_choice.update(status: :declined, declined_at: now + 5.days)

      expect(described_class.new(application_choice).offer_declined).to eq(now + 5.days)
    end
  end

  describe '#offer_accepted' do
    it 'returns nil if application has never been accepted' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :offer, application_form: application_form)

      expect(described_class.new(application_choice).offer_accepted).to be_nil
    end

    it 'returns time when offer was accepted' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :offer, application_form: application_form)
      application_choice.update(status: :pending_conditions, accepted_at: now + 5.days)

      expect(described_class.new(application_choice).offer_accepted).to eq(now + 5.days)
    end
  end

  describe '#dbd_date' do
    it 'returns the correct timestamp' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :awaiting_provider_decision,
        decline_by_default_at: now + 10.days,
        application_form: application_form,
      )

      expect(described_class.new(application_choice).dbd_date).to eq(now + 10.days)
    end
  end

  describe '#dbd_reminder_sent' do
    it 'returns nil when no chaser has been sent' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :offer,
        application_form: application_form,
      )

      expect(described_class.new(application_choice).dbd_reminder_sent).to be_nil
    end

    it 'returns the time when the chaser was sent' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :offer,
        application_form: application_form,
      )

      Timecop.freeze(now + 1.day) do
        ChaserSent.create!(chased: application_choice, chaser_type: :candidate_decision_request)
      end

      expect(described_class.new(application_choice).dbd_reminder_sent).to eq(now + 1.day)
    end
  end

  describe '#conditions_outcome' do
    it 'returns nil if the status has never been set' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)

      expect(described_class.new(application_choice).conditions_outcome).to be_nil
    end

    it 'returns time when application moved to recruited status' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)
      application_choice.update(status: :recruited, recruited_at: now + 5.days)

      expect(described_class.new(application_choice).conditions_outcome).to eq(now + 5.days)
    end

    it 'returns time when application moved to conditions_not_met status' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)
      application_choice.update(status: :conditions_not_met, conditions_not_met_at: now + 5.days)

      expect(described_class.new(application_choice).conditions_outcome).to eq(now + 5.days)
    end
  end

  describe '#conditions_met' do
    it 'returns nil if the status has never been set' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)

      expect(described_class.new(application_choice).conditions_met).to be_nil
    end

    it 'returns time when application moved to recruited status' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)
      application_choice.update(status: :recruited, recruited_at: now + 5.days)

      expect(described_class.new(application_choice).conditions_met).to eq(now + 5.days)
    end
  end

  describe '#conditions_not_met' do
    it 'returns nil if the status has never been set' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)

      expect(described_class.new(application_choice).conditions_not_met).to be_nil
    end

    it 'returns time when application moved to conditions_not_met status' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)
      application_choice.update(status: :conditions_not_met, conditions_not_met_at: now + 5.days)

      expect(described_class.new(application_choice).conditions_not_met).to eq(now + 5.days)
    end
  end

  describe '#ended_without_success' do
    it 'returns nil if an unsuccessful end status has never been set' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :recruited, application_form: application_form)

      expect(described_class.new(application_choice).ended_without_success).to be_nil
    end

    it 'returns time when application moved to rejected status' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)
      Timecop.freeze(now + 5.days) do
        application_choice.update(status: :rejected, rejected_at: Time.zone.now)
      end

      expect(described_class.new(application_choice).ended_without_success).to eq(now + 5.days)
    end

    it 'returns time when application moved to conditions_not_met status', audited: true do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)
      Timecop.freeze(now + 5.days) do
        application_choice.update(status: :conditions_not_met, conditions_not_met_at: Time.zone.now)
      end

      expect(described_class.new(application_choice).ended_without_success).to eq(now + 5.days)
    end
  end
end

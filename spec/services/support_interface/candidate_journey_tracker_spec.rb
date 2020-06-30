require 'rails_helper'

RSpec.describe SupportInterface::CandidateJourneyTracker, with_audited: true do
  let(:now) { Time.zone.local(2020, 6, 6, 12, 30, 24) }

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
      application_form = create(:application_form, created_at: Time.zone.local(2020, 6, 1))
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form, created_at: Time.zone.local(2020, 6, 2))

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq application_choice.created_at
    end

    it 'returns the time when the application form was first updated if this is recorded in the audit trail', audited: true do
      application_form = create(:application_form, created_at: Time.zone.local(2020, 6, 1))
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form, created_at: Time.zone.local(2020, 6, 7))
      application_form.update(phone_number: '01234 567890')

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq now
    end

    it 'returns the time when the application choice was created if this is earlier than any audit trail updated entries', audited: true do
      application_form = create(:application_form, created_at: Time.zone.local(2020, 6, 1))
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form, created_at: Time.zone.local(2020, 6, 5))
      application_form.update(phone_number: '01234 567890')

      expect(described_class.new(application_choice).form_started_and_not_submitted).to eq application_choice.created_at
    end
  end

  describe '#submitted_and_awaiting_references' do
    it 'returns the time when the application form was submitted' do
      submitted_at = Time.zone.local(2020, 6, 2, 12, 10, 0)
      application_form = create(:application_form, submitted_at: submitted_at)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).submitted_and_awaiting_references).to eq submitted_at
    end

    it 'returns nil if the application form has not been submitted' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).submitted_and_awaiting_references).to be_nil
    end
  end

  describe '#reference_1_received' do
    it 'returns nil if not references were received' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)

      expect(described_class.new(application_choice).reference_1_received).to be_nil
    end

    it 'returns the time when the first reference was received' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)
      application_reference = create(:reference, :requested, application_form: application_form)
      Timecop.freeze(now + 1.day) do
        application_reference.update!(feedback_status: 'feedback_provided')
      end
      expect(described_class.new(application_choice).reference_1_received).to eq(now + 1.day)
    end
  end

  describe '#reference_2_received' do
    it 'returns nil if only one reference has been received' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)
      application_reference1 = create(:reference, :requested, application_form: application_form)
      _application_reference2 = create(:reference, :requested, application_form: application_form)
      Timecop.freeze(now + 1.day) do
        application_reference1.update!(feedback_status: 'feedback_provided')
      end
      expect(described_class.new(application_choice).reference_2_received).to be_nil
    end

    it 'returns the time when the second reference was received' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :unsubmitted, application_form: application_form)
      application_reference1 = create(:reference, :requested, application_form: application_form)
      application_reference2 = create(:reference, :requested, application_form: application_form)
      Timecop.freeze(now + 1.day) do
        application_reference1.update!(feedback_status: 'feedback_provided')
      end
      Timecop.freeze(now + 2.days) do
        application_reference2.update!(feedback_status: 'feedback_provided')
      end
      expect(described_class.new(application_choice).reference_2_received).to eq(now + 2.days)
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
      application_choice = create(:application_choice, status: :awaiting_references, application_form: application_form)
      application_reference1 = create(:reference, :requested, application_form: application_form)
      application_reference2 = create(:reference, :requested, application_form: application_form)
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
      application_choice = create(:application_choice, status: :awaiting_references, application_form: application_form)
      create(:reference, :requested, application_form: application_form)
      application_reference2 = create(:reference, :refused, application_form: application_form)
      Timecop.freeze(now + 1.day) do
        ChaserSent.create!(chased: application_reference2, chaser_type: :reference_replacement)
      end

      expect(described_class.new(application_choice).new_reference_request_email_sent).to eq(now + 1.day)
    end
  end

  describe '#new_reference_added' do
    it 'returns nil when there are only two references' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_references, application_form: application_form)
      create(:reference, :requested, application_form: application_form)
      create(:reference, :requested, application_form: application_form)

      expect(described_class.new(application_choice).new_reference_added).to be_nil
    end

    it 'returns time of the earliest chaser sent' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_references, application_form: application_form)
      create(:reference, :requested, application_form: application_form)
      create(:reference, :refused, application_form: application_form)

      Timecop.freeze(now + 1.day) do
        create(:reference, :requested, application_form: application_form)
      end

      expect(described_class.new(application_choice).new_reference_added).to eq(now + 1.day)
    end
  end

  describe '#references_completed' do
    it 'returns nil when references_complete is not present in the audit trail' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_references, application_form: application_form)

      expect(described_class.new(application_choice).references_completed).to be_nil
    end

    it 'returns the first time when the value changed to true in the audit trail' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_references, application_form: application_form)
      Timecop.freeze(now + 1.day) { application_form.update(references_completed: true) }
      Timecop.freeze(now + 2.days) { application_form.update(references_completed: false) }
      Timecop.freeze(now + 3.days) { application_form.update(references_completed: true) }

      expect(described_class.new(application_choice).references_completed).to eq(now + 1.day)
    end
  end

  describe '#waiting_to_be_sent_to_provider' do
    it 'returns nil if the application never made it to application_complete status' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_references, application_form: application_form)

      expect(described_class.new(application_choice).references_completed).to be_nil
    end

    it 'returns the first time when the status changed to `application_complete` in the audit trail', audited: true do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_references, application_form: application_form)
      Timecop.freeze(now + 1.day) { application_choice.update(status: 'application_complete') }

      expect(described_class.new(application_choice).waiting_to_be_sent_to_provider).to eq(now + 1.day)
    end
  end

  describe '#application_sent_to_provider' do
    it 'returns the correct timestamp' do
      application_form = create(:application_form)
      application_choice = create(
        :application_choice,
        status: :awaiting_provider_decision,
        sent_to_provider_at: now + 1.day,
        application_form: application_form,
      )

      expect(described_class.new(application_choice).application_sent_to_provider).to eq(now + 1.day)
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

  describe '#pending_conditions' do
    it 'returns nil if the status has never been set' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)

      expect(described_class.new(application_choice).pending_conditions).to be_nil
    end

    it 'returns time when application moved to pending_conditions status' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)
      application_choice.update(status: :pending_conditions, accepted_at: now + 5.days)
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

  describe '#enrolled' do
    it 'returns nil if the status has never been set' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :recruited, application_form: application_form)

      expect(described_class.new(application_choice).enrolled).to be_nil
    end

    it 'returns time when application moved to enrolled status' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, status: :pending_conditions, application_form: application_form)
      application_choice.update(status: :enrolled, enrolled_at: now + 5.days)

      expect(described_class.new(application_choice).enrolled).to eq(now + 5.days)
    end
  end
end

# Form not started - created_at?
# Form started but unsubmitted - first audit trail update?
# Submiited & awaiting References - submitted_at
# Ref 1 recieved - from audit trail (reference status change)?
# Ref 2 recieved - from audit trail (reference status change)?
# Ref Reminder email sent - from chasers sent (chaser_type: :reference_request) (QUESTION: could be more than once)
# New ref req email sent - emails?
# New Ref added - ?
# References complete - from audit trail when `ApplicationForm#references_completed` gets set to true? (can happen more than once)
# Waiting to be sent to provider - not sure what this one means
# Application Sent to Provider - `ApplicationChoice#sent_to_provider_at`
# Awaiting Decision - not sure what this means (isn't it the same as `sent_to_provider_at`?)
# RBD Date - `ApplicationChoice#sent_to_provider_at`
# RBD Reminder Sent - Is this the `chase_provider_decision` email? `ChaserSent#provider_decision_request` ?
# Application RBD - Combination of `ApplicationChoice#rejected_at` and `rejected_by_default`
# Provider Decision (Reject/Offer) - `ApplicationChoice#rejected_at` or `ApplicationChoice#offered_at`
# Offer made, awaiting decision from candidate - `ApplicationChoice#offered_at`
# Email sent to candidate - the offer email? also the reject email?
# DBD Date - `ApplicationChoice#decline_by_default_at`
# DBD reminder email - `ChaserSent#chaser_type`
# Candidate Decision (accept/decline) - `ApplicationChoice#accepted_at` or `ApplicationChoice#declined_at`
# Offer declined - `ApplicationChoice#declined_at`
# Offer accepted - `ApplicationChoice#accepted_at`
# Email sent to candidate - the offer accepted email? QUESTION
# Pending Conditions - from audit trail
# Conditions Outcome - from audit trail
# Conditions Met - from audit trail
# Conditions Not Met - from audit trail
# Enrolled - from audit trail
# Ended without success - ?
# Send rejection email - emails?

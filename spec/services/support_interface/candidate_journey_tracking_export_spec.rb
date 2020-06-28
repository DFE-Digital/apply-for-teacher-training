require 'rails_helper'

RSpec.describe SupportInterface::CandidateJourneyTrackingExport, with_audited: true do
  describe '#application_choices' do
    it 'returns application choices with timings' do
      unsubmitted_form = create(:application_form)
      create(:application_choice, status: :unsubmitted, application_form: unsubmitted_form)
      create(:completed_application_form, application_choices_count: 2)

      choices = described_class.new.application_choices
      expect(choices.size).to eq(3)
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

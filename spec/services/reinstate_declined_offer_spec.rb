require 'rails_helper'

RSpec.describe ReinstateDeclinedOffer, :with_audited do
  describe '#save!' do
    it 'updates the application course choice status back to "offer made" and resets the DBD days back to 10' do
      course_choice = create(:application_choice, status: :offer)
      original_course_choice = course_choice.clone
      zendesk_ticket = 'www.becomingateacher.zendesk.com/agent/tickets/example'

      DeclineOffer.new(application_choice: course_choice).save!
      described_class.new(course_choice:, zendesk_ticket:).save!

      expect(course_choice).to eq original_course_choice
      expect(course_choice.audits.last.comment).to include(zendesk_ticket)
      expect(course_choice.withdrawn_or_declined_for_candidate_by_provider).to be_nil
    end

    it 'resets the DBD of the other application choices with an offer status and ignores any without' do
      zendesk_ticket = 'www.becomingateacher.zendesk.com/agent/tickets/example'
      application_form = create(:completed_application_form)

      declined_course_choice = create(:application_choice, :declined, application_form:)
      create(:application_choice, :offered, application_form:)
      course_choice_awaiting_decision = create(:application_choice, status: :awaiting_provider_decision, application_form:)

      described_class.new(course_choice: declined_course_choice, zendesk_ticket:).save!

      expect(declined_course_choice).to have_attributes({
        status: 'offer',
        declined_at: nil,
      })

      expect(declined_course_choice.audits.last.comment).to eq "Reinstate offer Zendesk request: #{zendesk_ticket}"

      expect(course_choice_awaiting_decision.reload).to eq course_choice_awaiting_decision
    end
  end
end

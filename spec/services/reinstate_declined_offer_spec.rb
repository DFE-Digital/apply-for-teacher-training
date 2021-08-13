require 'rails_helper'

RSpec.describe ReinstateDeclinedOffer, with_audited: true do
  describe '#save!' do
    it 'updates the application course choice status back to "offer made" and resets the DBD days back to 10' do
      Timecop.freeze do
        course_choice = create(:application_choice, status: :offer)
        original_course_choice = course_choice.clone
        zendesk_ticket = 'www.becomingateacher.zendesk.com/agent/tickets/example'

        DeclineOffer.new(application_choice: course_choice).save!
        described_class.new(course_choice: course_choice, zendesk_ticket: zendesk_ticket).save!

        expect(course_choice).to eq original_course_choice
        expect(course_choice.audits.last.comment).to include(zendesk_ticket)
      end
    end

    it 'resets the DBD of the other application choices with an offer status and ignores any without' do
      Timecop.freeze do
        zendesk_ticket = 'www.becomingateacher.zendesk.com/agent/tickets/example'
        application_form = create(:completed_application_form)

        declined_course_choice = create(:application_choice, :with_declined_offer, application_form: application_form)
        offered_course_choice = create(:application_choice, :with_offer, application_form: application_form)
        course_choice_awaiting_decision = create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)

        described_class.new(course_choice: declined_course_choice, zendesk_ticket: zendesk_ticket).save!

        expect(declined_course_choice).to have_attributes({
          status: 'offer',
          declined_at: nil,
          decline_by_default_at: 10.business_days.from_now.end_of_day,
        })

        expect(declined_course_choice.audits.last.comment).to eq "Reinstate offer Zendesk request: #{zendesk_ticket}"

        expect(offered_course_choice.reload.decline_by_default_at.round).to be_within(1.second).of 10.business_days.from_now.end_of_day

        expect(offered_course_choice.audits.last.comment).to eq "DBD reset due to a reinstated offer on application choice #{declined_course_choice.id} from ticket: #{zendesk_ticket}"

        expect(course_choice_awaiting_decision.reload).to eq course_choice_awaiting_decision
      end
    end
  end
end

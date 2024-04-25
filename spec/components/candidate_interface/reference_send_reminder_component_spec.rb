require 'rails_helper'

RSpec.describe CandidateInterface::ReferenceSendReminderComponent, type: :component do
  context 'when candidate can send a reminder to the referee' do
    context 'when the reminder was not sent' do
      it 'renders the button to send the reminder' do
        application_form = create(:application_form)
        reference = create(:reference, :feedback_requested, reminder_sent_at: nil, application_form:)
        result = render_inline(described_class.new(reference))
        expect(result.text).to include(t('application_form.references.send_reminder.post_offer_action'))
        expect(result.text).not_to include('You will be able')
      end
    end

    context 'when a reminder was sent' do
      it 'renders the button to send the reminder' do
        application_form = create(:application_form)
        reference = create(:reference, :feedback_requested, reminder_sent_at: 49.hours.ago, application_form:)
        result = render_inline(described_class.new(reference))
        expect(result.text).to include(t('application_form.references.send_reminder.post_offer_action'))
        expect(result.text).not_to include('You will be able')
      end
    end
  end

  context 'when candidate can not send a reminder to the referee' do
    it 'renders a message explaining when candidate can send the reminder' do
      travel_temporarily_to(Time.zone.local(2022, 1, 1, 10, 10, 10)) do
        application_form = create(:application_form)
        reference = create(:reference, :feedback_requested, reminder_sent_at: Time.zone.now, application_form:)
        result = render_inline(described_class.new(reference))
        expect(result.text).to include(I18n.t('application_form.references.send_reminder.remind_again', remind_again_at: '3 January 2022 at 10:10am'))
        expect(result.text).not_to include(t('application_form.references.send_reminder.post_offer_action'))
      end
    end
  end
end

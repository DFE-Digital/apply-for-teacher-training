require 'rails_helper'

RSpec.describe SetDeclineByDefaultToEndOfCycle do
  describe '#call' do
    let(:application_form) { create(:completed_application_form, application_choices_count: 3) }
    let(:choices) { application_form.application_choices }
    let(:now) { Time.zone.now }
    let(:call_service) { described_class.new(application_form:).call }

    before { set_time(now) }

    def expect_timestamps_to_match_excluding_milliseconds(first, second)
      expect(first.change(usec: 0)).to eq(second.change(usec: 0))
    end

    def expect_all_relevant_decline_by_default_at_values_to_be(expected)
      application_form.application_choices.reload.each do |application_choice|
        next unless application_choice.offer?

        dbd_at = application_choice.decline_by_default_at

        if expected
          expect_timestamps_to_match_excluding_milliseconds(dbd_at, expected)
        else
          expect(dbd_at).to be_nil
        end
      end
    end

    context 'when no offers or rejections have been made for any of the application choices' do
      it 'the DBD is not set for any of the application_choices' do
        choices[0].update(status: :awaiting_provider_decision)
        choices[1].update(status: :awaiting_provider_decision)
        choices[2].update(status: :awaiting_provider_decision)

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be nil
      end
    end

    context 'when one offer was made, and some decisions are pending' do
      it 'the DBD is not set for any of the application_choices' do
        choices[0].update(status: :offer, offered_at: 1.business_days.before(now).end_of_day)
        choices[1].update(status: :awaiting_provider_decision)
        choices[2].update(status: :awaiting_provider_decision)

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be nil
      end
    end

    context 'when one offer was made, and the rest are in the interviewing state' do
      it 'the DBD is not set for any of the application_choices' do
        choices[0].update(status: :offer, offered_at: 1.business_days.before(now))
        choices[1].update(status: :interviewing)
        choices[2].update(status: :interviewing)

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be nil
      end
    end

    context 'when all application choices have been rejected' do
      it 'the DBD is not set for any of the application_choices' do
        choices[0].update(status: :rejected, rejected_at: 1.business_days.before(now).end_of_day)
        choices[1].update(status: :rejected, rejected_at: 2.business_days.before(now).end_of_day)

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be nil
      end
    end

    context 'when one application choice has been offered and another withdrawn at a later date' do
      it 'the DBD is maintained for the offered application at end of cycle date' do
        withdrawal_date = 1.business_day.before(now).end_of_day

        choices[0].update(status: :offer, offered_at: 10.business_days.before(now).end_of_day)
        choices[1].update(status: :withdrawn, withdrawn_at: withdrawal_date)

        call_service

        dbd_for_offered_choice = choices[0].reload.decline_by_default_at

        expect_timestamps_to_match_excluding_milliseconds(dbd_for_offered_choice, CycleTimetable.next_apply_deadline)
      end
    end

    context 'when the application choice decline by default period spans a BST offset adjustment' do
      let(:now) { Time.zone.local(2021, 3, 27, 12, 10, 10) }

      it 'the DBD is set to the correct date and time allowing for offset' do
        choices[0].update(status: :offer, offered_at: 4.business_days.before(now))
        choices[1].update(status: :offer, offered_at: 4.business_days.before(now))
        choices[2].update(status: :offer, offered_at: 4.business_days.before(now))

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be CycleTimetable.next_apply_deadline
      end
    end

    context 'when the service is run multiple times' do
      let(:last_decision_at) { 2.business_days.before(now).end_of_day }
      let(:old_dbd_date) { 10.business_days.after(last_decision_at) }

      before do
        choices[0].update(status: :rejected, rejected_at: 2.business_days.before(last_decision_at))
        choices[1].update(
          status: :offer,
          offered_at: last_decision_at,
          decline_by_default_at: old_dbd_date,
        )
        choices[2].update(
          status: :offer,
          offered_at: last_decision_at,
          decline_by_default_at: old_dbd_date,
        )
      end

      it 'the DBD for all offers is extended if an offer is updated' do
        choices[1].update(
          status: :offer,
          offered_at: last_decision_at,
          offer_changed_at: last_decision_at + 1.day,
        )

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be CycleTimetable.next_apply_deadline
      end
    end

    it 'does not set DBD fields on non-offer application_choices (e.g. rejected/withdrawn)' do
      choices[0].update(status: :offer, offered_at: 1.business_days.before(now).end_of_day)
      choices[1].update(status: :rejected, rejected_at: 2.business_days.before(now).end_of_day)
      choices[2].update(status: :withdrawn, offered_at: 3.business_days.before(now).end_of_day)

      call_service

      choices.where.not(status: :offer).each do |choice|
        expect(choice.reload.decline_by_default_at).to be_nil
        expect(choice.reload.decline_by_default_days).to be_nil
      end
    end

    it 'does not update dates when nothing changes', with_audited: true do
      choices[0].update(status: :offer, offered_at: 2.business_days.before(now).end_of_day)

      expect { call_service }.to change { Audited::Audit.count }.by(1)
      expect { call_service }.not_to change(Audited::Audit, :count)
    end
  end
end

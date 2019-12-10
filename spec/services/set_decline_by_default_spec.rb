require 'rails_helper'

RSpec.describe SetDeclineByDefault do
  describe '#call' do
    let(:application_form) { create(:completed_application_form, application_choices_count: 3) }
    let(:choices) { application_form.application_choices }
    let(:time_limit_calculator) { instance_double('TimeLimitCalculator', call: 10) }
    let(:now) { Time.zone.local(2019, 11, 26, 12, 0, 0) }
    let(:call_service) { SetDeclineByDefault.new(application_form: application_form).call }

    before { allow(TimeLimitCalculator).to receive(:new).and_return(time_limit_calculator) }

    around do |example|
      Timecop.freeze(now) do
        example.run
      end
    end

    def expect_timestamps_to_match_excluding_milliseconds(first, second)
      expect(first.change(usec: 0)).to eq(second.change(usec: 0))
    end

    def expect_all_relevant_decline_by_default_at_values_to_be(expected)
      application_form.application_choices.reload.each do |application_choice|
        if application_choice.status == 'offer'
          dbd_at = application_choice.decline_by_default_at

          if !expected.nil?
            expect_timestamps_to_match_excluding_milliseconds(dbd_at, expected)
          else
            expect(dbd_at).to be_nil
          end
        end
      end
    end

    context 'when all the application choices have an offer' do
      it 'the DBD is set to 10 business days from the date of the most recent offer' do
        choices[0].update(status: :offer, offered_at: 1.business_days.before(now))
        choices[1].update(status: :offer, offered_at: 2.business_days.before(now))
        choices[2].destroy # this tests that we can handle fewer than 3 choices

        expected_dbd_date = 9.business_days.after(now).end_of_day

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be expected_dbd_date
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
        choices[0].update(status: :offer, offered_at: 1.business_days.before(now))
        choices[1].update(status: :awaiting_provider_decision)
        choices[2].update(status: :awaiting_provider_decision)

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be nil
      end
    end

    context 'when one offer was made, and two decisions are rejected' do
      it 'the DBD is set to 10 business days from the date of the most recent decision' do
        choices[0].update(status: :offer, offered_at: 1.business_days.before(now))
        choices[1].update(status: :rejected, rejected_at: 2.business_days.before(now))
        choices[2].update(status: :rejected, rejected_at: 3.business_days.before(now))

        expected_dbd_date = 9.business_days.after(now).end_of_day

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be expected_dbd_date
      end
    end

    context 'when the most recent decision is a rejection' do
      it 'the DBD is set to 10 business days from the date of this rejection' do
        choices[0].update(status: :rejected, rejected_at: 3.business_days.before(now))
        choices[1].update(status: :offer, offered_at: 2.business_days.before(now))
        choices[2].update(status: :rejected, rejected_at: 1.business_days.before(now))

        expected_dbd_date = 9.business_days.after(now).end_of_day

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be expected_dbd_date
      end
    end

    context 'when all application choices have been rejected' do
      it 'the DBD is not set for any of the application_choices' do
        choices[0].update(status: :rejected, rejected_at: 1.business_days.before(now))
        choices[1].update(status: :rejected, rejected_at: 2.business_days.before(now))

        call_service

        expect_all_relevant_decline_by_default_at_values_to_be nil
      end
    end

    context 'when one application choice has been offered and another withdrawn at a later date' do
      it 'the DBD is set for the offered application using the withdrawal date' do
        withdrawal_date = 1.business_day.before(now)

        choices[0].update(status: :offer, offered_at: 10.business_days.before(now))
        choices[1].update(status: :withdrawn, withdrawn_at: withdrawal_date)

        call_service

        dbd_for_offered_choice = choices[0].reload.decline_by_default_at
        expected_dbd_date = 10.business_days.after(withdrawal_date).end_of_day

        expect_timestamps_to_match_excluding_milliseconds(dbd_for_offered_choice, expected_dbd_date)
      end
    end

    context 'when the service is run multiple times' do
      let(:last_decision_at) { 2.business_days.before(now) }
      let(:old_dbd_date) { 8.business_days.after(now).end_of_day }

      before {
        choices[0].update(status: :rejected, rejected_at: 2.business_days.before(last_decision_at))
        choices[1].update(
          status: :offer,
          offered_at: last_decision_at,
          decline_by_default_at: old_dbd_date,
          decline_by_default_days: 10,
        )
        choices[2].update(
          status: :offer,
          offered_at: last_decision_at,
          decline_by_default_at: old_dbd_date,
          decline_by_default_days: 10,
        )
      }

      it 'the DBD for all offers is extended if an offer is updated' do
        choices[1].update(status: :offer, offered_at: last_decision_at + 1.day)

        call_service

        # adding 1 day to a time _after business hours_ takes you 2.business_days fwd
        new_dbd_date = 1.business_days.after(old_dbd_date - 12.hours).end_of_day

        expect_all_relevant_decline_by_default_at_values_to_be new_dbd_date
      end

      it 'the DBD for all offers is extended if an offer becomes a rejection' do
        choices[1].update(status: :rejected, rejected_at: last_decision_at + 1.day)

        call_service

        # adding 1 day to a time _after business hours_ takes you 2.business_days fwd
        new_dbd_date = 1.business_days.after(old_dbd_date - 12.hours).end_of_day
        expect_all_relevant_decline_by_default_at_values_to_be new_dbd_date
      end

      it 'the DBD for all offers is extended if a rejection becomes an offer' do
        choices[0].update(status: :offer, offered_at: last_decision_at + 1.day)

        call_service

        # adding 1 day to a time _after business hours_ takes you 2.business_days fwd
        new_dbd_date = 1.business_days.after(old_dbd_date - 12.hours).end_of_day
        expect_all_relevant_decline_by_default_at_values_to_be new_dbd_date
      end
    end

    it 'the decline_by_default_days is set to 10 days when DBD is present' do
      choices[0].update(status: :offer, offered_at: 1.business_days.before(now))
      choices[1].update(status: :offer, offered_at: 2.business_days.before(now))
      choices[2].update(status: :offer, offered_at: 2.business_days.before(now))

      call_service

      choices.each do |choice|
        expect(choice.reload.decline_by_default_days).to eq 10
      end
    end

    it 'does not set DBD fields on non-offer application_choices (e.g. rejected/withdrawn)' do
      choices[0].update(status: :offer, offered_at: 1.business_days.before(now))
      choices[1].update(status: :rejected, rejected_at: 2.business_days.before(now))
      choices[2].update(status: :withdrawn, offered_at: 3.business_days.before(now))

      call_service

      choices.where.not(status: :offer).each do |choice|
        expect(choice.reload.decline_by_default_at).to be_nil
        expect(choice.reload.decline_by_default_days).to be_nil
      end
    end
  end
end

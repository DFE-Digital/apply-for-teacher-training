require 'rails_helper'

RSpec.describe SupportInterface::ApplicationChoicesExport, with_audited: true do
  describe '#application_choices' do
    it 'returns submitted application choices with timings' do
      unsubmitted_form = create(:application_form)
      create(:application_choice, status: :unsubmitted, application_form: unsubmitted_form)
      submitted_form = create(:completed_application_form, application_choices_count: 2)

      choices = described_class.new.application_choices
      expect(choices.size).to eq(2)

      expect(choices).to contain_exactly(
        {
          candidate_id: submitted_form.candidate_id,
          recruitment_cycle_year: submitted_form.recruitment_cycle_year,
          support_reference: submitted_form.support_reference,
          phase: submitted_form.phase,
          submitted_at: submitted_form.submitted_at,
          choice_id: submitted_form.application_choices[0].id,
          choice_status: submitted_form.application_choices[0].status,
          provider_code: submitted_form.application_choices[0].course.provider.code,
          course_code: submitted_form.application_choices[0].course.code,
          sent_to_provider_at: nil,
          reject_by_default_at: nil,
          decline_by_default_at: nil,
          decided_at: nil,
          decision: nil,
          offer_response: nil,
          offer_response_at: nil,
          recruited_at: nil,
          rejection_reason: nil,
          structured_rejection_reasons: nil,
        },
        {
          candidate_id: submitted_form.candidate_id,
          recruitment_cycle_year: submitted_form.recruitment_cycle_year,
          support_reference: submitted_form.support_reference,
          phase: submitted_form.phase,
          submitted_at: submitted_form.submitted_at,
          choice_id: submitted_form.application_choices[1].id,
          choice_status: submitted_form.application_choices[1].status,
          provider_code: submitted_form.application_choices[1].course.provider.code,
          course_code: submitted_form.application_choices[1].course.code,
          sent_to_provider_at: nil,
          reject_by_default_at: nil,
          decline_by_default_at: nil,
          decided_at: nil,
          decision: nil,
          offer_response: nil,
          offer_response_at: nil,
          recruited_at: nil,
          rejection_reason: nil,
          structured_rejection_reasons: nil,
        },
      )
    end

    context 'for choices that have gone to a provider' do
      it 'returns the time that a choice was sent to the provider' do
        application_choice = create(:application_choice, :unsubmitted)

        SubmitApplication.new(application_choice.application_form).call

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(sent_to_provider_at: application_choice.reload.sent_to_provider_at)
        expect(choice_row).to include(decided_at: nil)
        expect(choice_row).to include(decision: :awaiting_provider)
      end

      it 'returns the decision outcome and time for offers' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :with_offer, offered_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(decided_at: decision_time)
        expect(choice_row).to include(decision: :offered)
      end

      it 'returns the decision outcome and time for rejections' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(
          :application_choice,
          :with_rejection,
          rejected_at: decision_time,
          rejection_reason: 'Does not have curriculum knowledge',
        )
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(decided_at: decision_time)
        expect(choice_row).to include(decision: :rejected)
        expect(choice_row).to include(rejection_reason: 'Does not have curriculum knowledge')
      end

      it 'returns the decision outcome and time for rejections-by-default' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :with_rejection_by_default, rejected_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(decided_at: decision_time)
        expect(choice_row).to include(decision: :rejected_by_default)
      end
    end

    context 'for choices where the candidate has responded to an offer' do
      it 'returns the offer decision outcome and time for accepted offers' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :with_accepted_offer, accepted_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(offer_response_at: decision_time)
        expect(choice_row).to include(offer_response: :accepted)
      end

      it 'returns the offer decision outcome and time for declined offers' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :with_declined_offer, declined_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(offer_response_at: decision_time)
        expect(choice_row).to include(offer_response: :declined)
      end

      it 'returns the offer decision outcome and time for declined-by-default offers' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :with_declined_by_default_offer, declined_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(offer_response_at: decision_time)
        expect(choice_row).to include(offer_response: :declined_by_default)
      end
    end

    context 'for choices rejected with structured rejection reasons' do
      it 'returns formatted high level rejection reasons (those that include y_n)' do
        create(
          :application_choice,
          :with_completed_application_form,
          structured_rejection_reasons: {
            course_full_y_n: 'No',
            candidate_behaviour_y_n: 'Yes',
            candidate_behaviour_other: 'Persistent scratching',
            honesty_and_professionalism_y_n: 'Yes',
            honesty_and_professionalism_concerns: %w[references],
          },
        )

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(structured_rejection_reasons: "Candidate behaviour\nHonesty and professionalism")
      end
    end
  end
end

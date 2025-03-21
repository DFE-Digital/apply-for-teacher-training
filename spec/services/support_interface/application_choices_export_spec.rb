require 'rails_helper'

RSpec.describe SupportInterface::ApplicationChoicesExport, :with_audited do
  describe 'documentation' do
    before do
      create(:completed_application_form, application_choices_count: 2)
    end

    it_behaves_like 'a data export'
  end

  describe '#application_choices' do
    let(:previous_year) { RecruitmentCycleTimetable.previous_year }

    def expect_form(actual, form, choice:)
      expect(actual[:candidate_id]).to eq(form.candidate.id)
      expect(actual[:recruitment_cycle_year]).to eq(form.recruitment_cycle_year)
      expect(actual[:support_reference]).to eq(form.support_reference)
      expect(actual[:phase]).to eq(form.phase)
      expect(actual[:submitted_at].iso8601).to eq(form.submitted_at.iso8601)
      expect(actual[:application_choice_id]).to eq(choice.id)
      expect(actual[:choice_status]).to eq(choice.status)
      expect(actual[:provider_code]).to eq(choice.course.provider.code)
      expect(actual[:course_code]).to eq(choice.course.code)
      expect(actual[:sent_to_provider_at].iso8601).to eq(choice.sent_to_provider_at.iso8601)
      expect(actual[:reject_by_default_at].iso8601).to eq(choice.reject_by_default_at.iso8601)
      expect(actual[:decline_by_default_at]).to be_nil
      expect(actual[:decided_at]).to be_nil
      expect(actual[:decision]).to eq(:awaiting_provider)
      expect(actual[:offer_response]).to be_nil
      expect(actual[:offer_response_at]).to be_nil
      expect(actual[:recruited_at]).to be_nil
      expect(actual[:rejection_reason]).to be_nil
      expect(actual[:structured_rejection_reasons]).to be_nil
    end

    it 'returns submitted application choices with timings' do
      unsubmitted_form = create(:application_form)
      advance_time
      create(:application_choice, status: :unsubmitted, application_form: unsubmitted_form)
      advance_time
      previously_submitted_form = create(
        :completed_application_form,
        submitted_application_choices_count: 1,
        recruitment_cycle_year: previous_year,
      )
      advance_time
      submitted_form = create(:completed_application_form, submitted_application_choices_count: 2)

      choices = described_class.new.application_choices
      expect(choices.size).to eq(3)

      expect_form(choices[0], previously_submitted_form, choice: previously_submitted_form.application_choices.first)
      expect_form(choices[1], submitted_form, choice: submitted_form.application_choices.first)
      expect_form(choices[2], submitted_form, choice: submitted_form.application_choices.second)
    end

    it 'can export applications in the current cycle' do
      create(:completed_application_form, application_choices_count: 1)
      create(:completed_application_form, application_choices_count: 1, recruitment_cycle_year: previous_year)

      expect(described_class.new.application_choices('current_cycle' => true).size).to eq(1)
    end

    context 'for choices that have gone to a provider' do
      it 'returns the time that a choice was sent to the provider' do
        application_choice = create(:application_choice, :unsubmitted)

        CandidateInterface::SubmitApplicationChoice.new(application_choice).call

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(sent_to_provider_at: application_choice.reload.sent_to_provider_at)
        expect(choice_row).to include(decided_at: nil)
        expect(choice_row).to include(decision: :awaiting_provider)
      end

      it 'returns the decision outcome and time for offers' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :offered, offered_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(decided_at: decision_time)
        expect(choice_row).to include(decision: :offered)
      end

      it 'returns the decision outcome and time for rejections' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(
          :application_choice,
          :rejected,
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
        choice = create(:application_choice, :rejected_by_default, rejected_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(decided_at: decision_time)
        expect(choice_row).to include(decision: :rejected_by_default)
      end
    end

    context 'for choices where the candidate has responded to an offer' do
      it 'returns the offer decision outcome and time for accepted offers' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :accepted, accepted_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(offer_response_at: decision_time)
        expect(choice_row).to include(offer_response: :accepted)
      end

      it 'returns the offer decision outcome and time for declined offers' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :declined, declined_at: decision_time)
        choice.application_form.update(submitted_at: Time.zone.now)

        choice_row = described_class.new.application_choices.first
        expect(choice_row).to include(offer_response_at: decision_time)
        expect(choice_row).to include(offer_response: :declined)
      end

      it 'returns the offer decision outcome and time for declined-by-default offers' do
        decision_time = Time.zone.local(2019, 10, 1, 12, 0, 0)
        choice = create(:application_choice, :declined_by_default, declined_at: decision_time)
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
        expect(choice_row).to include(structured_rejection_reasons: 'Something you did, Honesty and professionalism')
      end
    end
  end
end

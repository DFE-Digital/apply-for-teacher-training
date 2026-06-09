require 'rails_helper'

RSpec.describe EndOfCycle::SendWinterRejectByDefaultExplainerEmailToCandidatesWorker do
  let(:instance) { described_class.new }
  let(:previous_year) { RecruitmentCycleTimetable.previous_year }

  describe '#perform' do
    context 'before or after the date for sending the winter explainer email' do
      it 'does not enqueue the batch worker' do
        create(
          :application_choice,
          :rejected_by_default,
          current_recruitment_cycle_year: previous_year,
          application_form: create(:application_form, recruitment_cycle_year: previous_year),
        )
        allow(EndOfCycle::SendWinterRejectByDefaultExplainerEmailToCandidatesBatchWorker).to receive(:perform_at)
        instance.perform
        expect(EndOfCycle::SendWinterRejectByDefaultExplainerEmailToCandidatesBatchWorker).not_to have_received(:perform_at)
      end
    end

    context 'the date for sending the explainer email' do
      before do
        allow(instance).to receive(:send_emails?).and_return(true)
      end

      it 'enqueues batch worker' do
        september_course = create(:course, recruitment_cycle_year: previous_year, start_date: Date.parse("01/09/#{previous_year}"))
        january_course = create(:course, recruitment_cycle_year: previous_year, start_date: Date.parse("01/01/#{previous_year + 1}"))
        another_january_course = create(:course, recruitment_cycle_year: previous_year, start_date: Date.parse("01/01/#{previous_year + 1}"))
        duplication_january_course = create(
          :course,
          start_date: Date.parse("01/01/#{previous_year + 1}"),
        )
        rejected_with_offer = create(:application_form, recruitment_cycle_year: previous_year)
        create(
          :application_choice,
          :rejected_by_default,
          application_form: rejected_with_offer,
          current_recruitment_cycle_year: previous_year,
          course_option: create(:course_option, course: january_course),
        )
        create(
          :application_choice,
          :offered,
          application_form: rejected_with_offer,
          current_recruitment_cycle_year: previous_year,
          course_option: create(:course_option, course: another_january_course),
        )

        rejected_without_offer = create(:application_form, recruitment_cycle_year: previous_year)
        create(
          :application_choice,
          :rejected_by_default,
          application_form: rejected_without_offer,
          current_recruitment_cycle_year: previous_year,
          course_option: create(:course_option, course: january_course),
        )

        last_september_form = create(:application_form, recruitment_cycle_year: previous_year)
        create(
          :application_choice,
          :rejected_by_default,
          application_form: last_september_form,
          current_recruitment_cycle_year: previous_year,
          course_option: create(:course_option, course: september_course),
        )
        duplication_january_course_form = create(:application_form)
        create(
          :application_choice,
          :rejected_by_default,
          application_form: duplication_january_course_form,
          course_option: create(:course_option, course: duplication_january_course),
        )

        # These applications should not be included
        create(:application_choice, :inactive, application_form: build(:application_form, recruitment_cycle_year: previous_year))
        create(:application_choice, :interviewing, application_form: build(:application_form, recruitment_cycle_year: previous_year))
        create(:application_choice, :awaiting_provider_decision, application_form: build(:application_form, recruitment_cycle_year: previous_year))
        create(:application_choice, :rejected_by_default)

        allow(EndOfCycle::SendWinterRejectByDefaultExplainerEmailToCandidatesBatchWorker).to receive(:perform_at)
        instance.perform

        expect(EndOfCycle::SendWinterRejectByDefaultExplainerEmailToCandidatesBatchWorker)
          .to have_received(:perform_at).with(kind_of(Time), [rejected_with_offer.id, rejected_without_offer.id, duplication_january_course_form.id])
      end
    end
  end
end

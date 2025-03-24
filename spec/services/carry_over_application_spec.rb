require 'rails_helper'
require 'services/duplicate_application_shared_examples'

RSpec.describe CarryOverApplication do
  def original_application_form
    @original_application_form ||= travel_temporarily_to(-1.day) do
      application_form = create(
        :completed_application_form,
        :with_gcses,
        application_choices_count: 1,
        volunteering_experiences_count: 1,
        full_work_history: true,
        references_count: 0,
      )
      create(:reference, feedback_status: :feedback_provided, application_form:)
      create(:reference, feedback_status: :not_requested_yet, application_form:)
      create(:reference, feedback_status: :feedback_refused, application_form:)
      application_form
    end
  end

  before do
    TestSuiteTimeMachine.travel_permanently_to(after_apply_deadline)
  end

  let(:application_form) { create(:completed_application_form, references_count: 0) }

  context 'when application is waiting for references' do
    it 'sets the reference to the not_requested state' do
      create(:reference, feedback_status: :feedback_provided, application_form:)
      create(:reference, feedback_status: :feedback_requested, application_form:)
      create(:reference, feedback_status: :cancelled_at_end_of_cycle, application_form:)
      create(:reference, feedback_status: :feedback_refused, application_form:)

      described_class.new(application_form).call

      expect(ApplicationForm.count).to eq 2
      expect(ApplicationForm.last.application_references.count).to eq 3
      expect(ApplicationForm.last.application_references.creation_order.map(&:feedback_status)).to eq(
        %w[feedback_provided not_requested_yet not_requested_yet],
      )
    end
  end

  context 'when original application is from an earlier recruitment cycle' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
      original_application_form.recruitment_cycle_year = RecruitmentCycleTimetable.previous_year
      original_application_form.save(touch: false)
    end

    it_behaves_like 'duplicates application form', RecruitmentCycleTimetable.current_year
  end

  context 'when original application is from multiple cycles ago' do
    before do
      TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
      original_application_form.recruitment_cycle_year = RecruitmentCycleTimetable.previous_year - 1
      original_application_form.save(touch: false)
    end

    it_behaves_like 'duplicates application form', RecruitmentCycleTimetable.current_year
  end

  context 'when original application is from the current recruitment cycle but that cycle has now closed', time: after_apply_deadline do
    it_behaves_like 'duplicates application form', RecruitmentCycleTimetable.next_year
  end

  context 'when application form has unstructured work history', time: after_apply_deadline do
    it 'carries over history' do
      described_class.new(original_application_form).call
      carried_over_application_form = ApplicationForm.last

      expect(carried_over_application_form.application_work_experiences.count).to eq(2)
    end

    describe 'personal_details_completed' do
      it 'sets the personal details section to incomplete if nationality is not UK/Irish for 2021-22 carry over' do
        ApplicationForm.with_unsafe_application_choice_touches do
          original_application_form.update!(
            first_nationality: 'Indian',
            personal_details_completed: true,
            recruitment_cycle_year: 2021,
          )
          described_class.new(original_application_form).call
        end
        carried_over_application_form = ApplicationForm.last

        expect(carried_over_application_form.personal_details_completed).to be(false)
      end

      it 'does NOT set the personal details section to incomplete if nationality is UK/Irish for 2021-22 carry over' do
        original_application_form.update!(
          first_nationality: 'British',
          personal_details_completed: true,
          recruitment_cycle_year: 2021,
        )
        described_class.new(original_application_form).call
        carried_over_application_form = ApplicationForm.last

        expect(carried_over_application_form.personal_details_completed).to be(true)
      end
    end

    it 'only carries over required attributes' do
      described_class.new(original_application_form).call

      carried_over_application_form = ApplicationForm.last

      carried_over_application_form.application_work_experiences.each do |experience|
        expect(experience.working_pattern).to be_nil
        expect(experience.working_with_children).to be_nil
        expect(experience.role).to be_present
        expect(experience.organisation).to be_present
        expect(experience.details).to be_present
      end
    end

    it 'infers that `currently_working` is false if there is no ongoing work history item' do
      ApplicationForm.with_unsafe_application_choice_touches do
        first_job = original_application_form.application_work_experiences.first
        first_job.update(start_date: 4.years.ago, end_date: 3.years.ago)

        second_job = original_application_form.application_work_experiences.last
        second_job.update(start_date: 2.years.ago, end_date: 1.year.ago)

        described_class.new(original_application_form.reload).call

        carried_over_application_form = ApplicationForm.last
        expect(carried_over_application_form.application_work_experiences.find_by(start_date: first_job.start_date).currently_working?).to be(false)
        expect(carried_over_application_form.application_work_experiences.find_by(start_date: second_job.start_date).currently_working?).to be(false)
      end
    end

    it 'infers that `currently_working` is true if there is an ongoing work history item' do
      ApplicationForm.with_unsafe_application_choice_touches do
        first_job = original_application_form.application_work_experiences.first
        first_job.update(start_date: 3.years.ago, end_date: 2.years.ago)

        second_job = original_application_form.application_work_experiences.last
        second_job.update(start_date: 1.year.ago, end_date: nil, currently_working: nil)

        described_class.new(original_application_form.reload).call

        carried_over_application_form = ApplicationForm.last
        expect(carried_over_application_form.application_work_experiences.find_by(start_date: first_job.start_date).currently_working?).to be(false)
        expect(carried_over_application_form.application_work_experiences.find_by(start_date: second_job.start_date).currently_working?).to be(true)
      end
    end
  end
end

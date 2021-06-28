require 'rails_helper'
require 'services/duplicate_application_shared_examples'

RSpec.describe CarryOverApplication do
  include CycleTimetableHelper
  def original_application_form
    @original_application_form ||= Timecop.travel(-1.day) do
      application_form = create(
        :completed_application_form,
        :with_gcses,
        application_choices_count: 1,
        volunteering_experiences_count: 1,
        full_work_history: true,
      )
      create(:reference, feedback_status: :feedback_provided, application_form: application_form)
      create(:reference, feedback_status: :not_requested_yet, application_form: application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: application_form)
      application_form
    end
  end

  context 'when original application is from an earlier recruitment cycle' do
    around do |example|
      Timecop.freeze(after_apply_reopens) do
        example.run
      end
    end

    before do
      Timecop.travel(-1.day) { original_application_form.update(recruitment_cycle_year: 2020) }
    end

    it_behaves_like 'duplicates application form', 'apply_1', 2021
  end

  context 'when original application is from the current recruitment cycle but that cycle has now closed' do
    around do |example|
      Timecop.freeze(after_apply_2_deadline) do
        example.run
      end
    end

    it_behaves_like 'duplicates application form', 'apply_1', 2021
  end

  context 'when the application_form has references has an application_reference in the cancelled_at_end_of_cycle state' do
    around do |example|
      Timecop.freeze(after_apply_2_deadline) do
        example.run
      end
    end

    let(:application_form) { create(:completed_application_form) }

    it 'sets the reference to the not_requested state' do
      create(:reference, feedback_status: :feedback_provided, application_form: application_form)
      create(:reference, feedback_status: :cancelled_at_end_of_cycle, application_form: application_form)
      create(:reference, feedback_status: :feedback_refused, application_form: application_form)

      described_class.new(application_form).call

      expect(ApplicationForm.count).to eq 2
      expect(ApplicationForm.last.application_references.count).to eq 2
      expect(ApplicationForm.last.application_references.map(&:feedback_status)).to eq %w[feedback_provided not_requested_yet]
    end

    it 'does not carry over references whose feedback is overdue' do
      create(:reference, feedback_status: :cancelled_at_end_of_cycle, application_form: application_form, requested_at: 1.month.ago)
      create(:reference, feedback_status: :cancelled_at_end_of_cycle, application_form: application_form, requested_at: 1.month.ago)
      create(:reference, feedback_status: :cancelled_at_end_of_cycle, application_form: application_form, requested_at: 2.days.ago, name: 'Carrie Over')
      create(:reference, feedback_status: :cancelled_at_end_of_cycle, application_form: application_form, requested_at: 1.day.ago, name: 'Nixt Cycle')

      described_class.new(application_form).call

      expect(ApplicationForm.last.application_references.count).to eq 2
      expect(ApplicationForm.last.application_references.map(&:name)).to eq ['Carrie Over', 'Nixt Cycle']
    end
  end

  context 'when application form has unstructured work history' do
    before do
      original_application_form.update(feature_restructured_work_history: false)
      FeatureFlag.activate(:restructured_work_history)
    end

    it 'carries over history and sets feature_structured_work_history to true' do
      described_class.new(original_application_form).call
      carried_over_application_form = ApplicationForm.last

      expect(carried_over_application_form.application_work_experiences.count).to eq(2)
      expect(carried_over_application_form.feature_restructured_work_history).to be(true)
    end

    it 'sets the work history section to incomplete' do
      described_class.new(original_application_form).call
      carried_over_application_form = ApplicationForm.last

      expect(carried_over_application_form.work_history_completed).to be(false)
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
      first_job = original_application_form.application_work_experiences.first
      first_job.update(start_date: 4.years.ago, end_date: 3.years.ago)

      second_job = original_application_form.application_work_experiences.last
      second_job.update(start_date: 2.years.ago, end_date: 1.year.ago)

      described_class.new(original_application_form.reload).call

      expect(first_job.reload.currently_working?).to be(false)
      expect(second_job.reload.currently_working?).to be(false)
    end

    it 'infers that `currently_working` is true if there is an ongoing work history item' do
      first_job = original_application_form.application_work_experiences.first
      first_job.update(start_date: 3.years.ago, end_date: 2.years.ago)

      second_job = original_application_form.application_work_experiences.last
      second_job.update(start_date: 1.year.ago, end_date: nil)

      described_class.new(original_application_form.reload).call

      expect(first_job.reload.currently_working?).to be(false)
      expect(second_job.reload.currently_working?).to be(true)
    end
  end
end

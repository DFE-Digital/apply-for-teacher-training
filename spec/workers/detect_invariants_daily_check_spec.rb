require 'rails_helper'

RSpec.describe DetectInvariantsDailyCheck do
  before do
    allow(Raven).to receive(:capture_exception)

    # or unwanted exceptions will be thrown by this check
    TeacherTrainingPublicAPI::SyncCheck.set_last_sync(Time.zone.now)
  end

  describe '#perform' do
    it 'detects outstanding references on submitted applications' do
      weird_application_form = create(:completed_application_form)
      create(:submitted_application_choice, application_form: weird_application_form)
      create(:reference, :feedback_requested, application_form: weird_application_form)
      create(:reference, :feedback_provided, application_form: weird_application_form)

      # Two further applications with no reference weirdness
      ok_form_one = create(:completed_application_form)
      create(:submitted_application_choice, application_form: ok_form_one)
      create(:reference, :feedback_provided, application_form: ok_form_one)
      ok_form_two = create(:application_form)
      create(:reference, :feedback_requested, application_form: ok_form_two)

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::OutstandingReferencesOnSubmittedApplication.new(
          <<~MSG,
            One or more references are still pending on these applications,
            even though they've already been submitted:

            #{HostingEnvironment.application_url}/support/applications/#{weird_application_form.id}
          MSG
        ),
      )
    end

    it 'detects application choices for courses in the last cycle' do
      this_year_course = create(:course_option)
      last_year_course = create(:course_option, :previous_year)

      bad_form_this_year = create(:completed_application_form, submitted_at: Time.zone.now)
      good_form_this_year = create(:completed_application_form, submitted_at: Time.zone.now)
      good_form_last_year = create(:application_form, submitted_at: 1.year.ago)

      create(:application_choice, application_form: bad_form_this_year, course_option: last_year_course)
      create(:application_choice, application_form: good_form_this_year, course_option: this_year_course)
      create(:application_choice, application_form: good_form_last_year, course_option: last_year_course)

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::ApplicationHasCourseChoiceInPreviousCycle.new(
          <<~MSG,
            The following application forms have course choices from the previous recruitment cycle

            #{HostingEnvironment.application_url}/support/applications/#{bad_form_this_year.id}
          MSG
        ),
      )
    end

    it 'doesn’t alert when the course sync has succeeded recently' do
      described_class.new.perform

      expect(Raven).not_to have_received(:capture_exception)
    end

    it 'detects applications submitted with the same course' do
      course = create(:course)
      course_option1 = create(:course_option, course: course)
      course_option2 = create(:course_option, course: course)
      application_form = create(:completed_application_form)

      create(:submitted_application_choice, application_form: application_form, course_option: course_option1)
      create(:submitted_application_choice, application_form: application_form, course_option: course_option2)

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::ApplicationSubmittedWithTheSameCourse.new(
          <<~MSG,
            The following applications have been submitted containing the same course choice multiple times

            #{HostingEnvironment.application_url}/support/applications/#{application_form.id}
          MSG
        ),
      )
    end

    it 'detects when a submitted application has more than 2 selected references' do
      application_form_with_three_selected_references = create(:completed_application_form, :with_completed_references)
      create(:submitted_application_choice, application_form: application_form_with_three_selected_references)
      create(:reference, :feedback_provided, selected: true, application_form: application_form_with_three_selected_references)
      create(:reference, :feedback_provided, selected: true, application_form: application_form_with_three_selected_references)
      create(:reference, :feedback_provided, selected: true, application_form: application_form_with_three_selected_references)

      valid_application_form = create(:completed_application_form, :with_completed_references)
      create(:submitted_application_choice, application_form: valid_application_form)
      create(:reference, :feedback_provided, selected: true, application_form: valid_application_form)
      create(:reference, :feedback_provided, selected: true, application_form: valid_application_form)

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::ApplicationSubmittedWithMoreThanTwoSelectedReferences.new(
          <<~MSG,
            The following applications have been submitted with more than two selected references

            #{HostingEnvironment.application_url}/support/applications/#{application_form_with_three_selected_references.id}
          MSG
        ),
      )
    end

    it 'detects non-deferred application choices with a course from a different recruitment cycle' do
      application_form_with_invalid_course = create(:application_form)
      application_form_with_valid_course = create(:application_form)

      course_from_previous_cycle = create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year)
      course_from_current_cycle = create(:course, recruitment_cycle_year: RecruitmentCycle.current_year)

      old_course_option = create(:course_option, course: course_from_previous_cycle)
      new_course_option = create(:course_option, course: course_from_current_cycle)

      create(:application_choice, course_option: old_course_option, application_form: application_form_with_invalid_course)
      create(:application_choice, current_course_option: new_course_option, application_form: application_form_with_valid_course)
      create(:application_choice, course_option: old_course_option, application_form: application_form_with_valid_course, offer_deferred_at: Time.zone.now)

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::ApplicationWithADifferentCyclesCourse.new(
          <<~MSG,
            The following applications have an application choice with a course from a different recruitment cycle

            #{HostingEnvironment.application_url}/support/applications/#{application_form_with_invalid_course.id}
          MSG
        ),
      )
    end

    it 'detects submitted applications with more than three course choices' do
      create(:completed_application_form, submitted_application_choices_count: 3)
      bad_application_form = create(:completed_application_form, submitted_application_choices_count: 4)

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).once
      expect(Raven).to have_received(:capture_exception).with(
        described_class::SubmittedApplicationHasMoreThanThreeChoices.new(
          <<~MSG,
            The following application forms have been submitted with more than three course choices

            #{HostingEnvironment.application_url}/support/applications/#{bad_application_form.id}
          MSG
        ),
      )
    end
  end
end

require 'rails_helper'

RSpec.describe DetectInvariants do
  before do
    allow(Raven).to receive(:capture_exception)

    # or unwanted exceptions will be thrown by this check
    TeacherTrainingPublicAPI::SyncCheck.set_last_sync(Time.zone.now)
  end

  describe '#perform' do
    it 'detects application choices in deprecated states' do
      application_choice_bad = create(:application_choice)
      application_choice_bad.update_columns(status: 'application_complete')
      application_choice_bad_too = create(:application_choice)
      application_choice_bad_too.update_columns(status: 'awaiting_references')

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::ApplicationInRemovedState.new(
          <<~MSG,
            One or more application choices are still in `awaiting_references` or
            `application_complete` state, but all these states have been removed:

            #{HostingEnvironment.application_url}/support/application-choices/#{application_choice_bad.id}
            #{HostingEnvironment.application_url}/support/application-choices/#{application_choice_bad_too.id}
          MSG
        ),
      )
    end

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

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::OutstandingReferencesOnSubmittedApplication.new(
          <<~MSG,
            One or more references are still pending on these applications,
            even though they've already been submitted:

            #{HostingEnvironment.application_url}/support/applications/#{weird_application_form.id}
          MSG
        ),
      )
    end

    it 'detects unauthorised edits on data associated with an application form', with_audited: true do
      honest_bob = create(:candidate)
      nefarious_jim = create(:candidate)
      suspect_form = build(:application_form, candidate: honest_bob)
      ok_form = build(:application_form, candidate: nefarious_jim)

      Audited.audit_class.as_user(honest_bob) do
        suspect_form.save!
        create(:gcse_qualification, application_form: suspect_form, grade: 'A')
        suspect_form.application_qualifications.first.update(grade: 'A*')
      end
      Audited.audit_class.as_user(nefarious_jim) do
        ok_form.save!
        create(:gcse_qualification, application_form: ok_form, grade: 'B')
        ok_form.application_qualifications.first.update(grade: 'C')
        suspect_form.application_qualifications.first.update(grade: 'F')
      end

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::ApplicationEditedByWrongCandidate.new(
          <<~MSG,
            The following application forms have had edits by a candidate who is not the owner of the application:

            #{HostingEnvironment.application_url}/support/applications/#{suspect_form.id}
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

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::ApplicationHasCourseChoiceInPreviousCycle.new(
          <<~MSG,
            The following application forms have course choices from the previous recruitment cycle

            #{HostingEnvironment.application_url}/support/applications/#{bad_form_this_year.id}
          MSG
        ),
      )
    end

    it 'detects submitted applications with more than three course choices' do
      create(:completed_application_form, submitted_application_choices_count: 3)
      bad_application_form = create(:completed_application_form, submitted_application_choices_count: 4)

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).once
      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::SubmittedApplicationHasMoreThanThreeChoices.new(
          <<~MSG,
            The following application forms have been submitted with more than three course choices

            #{HostingEnvironment.application_url}/support/applications/#{bad_application_form.id}
          MSG
        ),
      )
    end

    it 'detects applications submitted with the same course' do
      course = create(:course)
      course_option1 = create(:course_option, course: course)
      course_option2 = create(:course_option, course: course)
      application_form = create(:completed_application_form)

      create(:submitted_application_choice, application_form: application_form, course_option: course_option1)
      create(:submitted_application_choice, application_form: application_form, course_option: course_option2)

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::ApplicationSubmittedWithTheSameCourse.new(
          <<~MSG,
            The following applications have been submitted containing the same course choice multiple times

            #{HostingEnvironment.application_url}/support/applications/#{application_form.id}
          MSG
        ),
      )
    end

    it 'ignores withdrawn and rejected application choices submitted with the same course' do
      course = create(:course)
      course_option1 = create(:course_option, course: course)
      course_option2 = create(:course_option, course: course)
      course_option3 = create(:course_option, course: course)
      application_form = create(:completed_application_form)

      create(:submitted_application_choice, status: :withdrawn, application_form: application_form, course_option: course_option1)
      create(:submitted_application_choice, status: :rejected, application_form: application_form, course_option: course_option2)
      create(:submitted_application_choice, application_form: application_form, course_option: course_option3)

      DetectInvariants.new.perform

      expect(Raven).not_to have_received(:capture_exception)
    end

    it 'detects when the course sync hasn’t succeeded for an hour' do
      TeacherTrainingPublicAPI::SyncCheck.clear_last_sync

      DetectInvariants.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        DetectInvariants::CourseSyncNotSucceededForAnHour.new(
          'The course sync via the Teacher training public API has not succeeded for an hour',
        ),
      )
    end

    it 'doesn’t alert when the course sync has succeeded recently' do
      DetectInvariants.new.perform

      expect(Raven).not_to have_received(:capture_exception)
    end
  end
end

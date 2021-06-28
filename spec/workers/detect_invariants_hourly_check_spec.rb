require 'rails_helper'

RSpec.describe DetectInvariantsHourlyCheck do
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

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::ApplicationInRemovedState.new(
          <<~MSG,
            One or more application choices are still in `awaiting_references` or
            `application_complete` state, but all these states have been removed:

            #{HostingEnvironment.application_url}/support/application-choices/#{application_choice_bad.id}
            #{HostingEnvironment.application_url}/support/application-choices/#{application_choice_bad_too.id}
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

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::ApplicationEditedByWrongCandidate.new(
          <<~MSG,
            The following application forms have had edits by a candidate who is not the owner of the application:

            #{HostingEnvironment.application_url}/support/applications/#{suspect_form.id}
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

      described_class.new.perform

      expect(Raven).not_to have_received(:capture_exception)
    end

    it 'detects when the course sync hasn’t succeeded for an hour' do
      TeacherTrainingPublicAPI::SyncCheck.clear_last_sync

      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::CourseSyncNotSucceededForAnHour.new(
          'The course sync via the Teacher training public API has not succeeded for an hour',
        ),
      )
    end

    it 'doesn’t alert when the course sync has succeeded recently' do
      described_class.new.perform

      expect(Raven).not_to have_received(:capture_exception)
    end

    it 'detects when the sidekiq retries queue is high' do
      sidekiq_retries = instance_double(Sidekiq::RetrySet, size: 100)
      allow(Sidekiq::RetrySet).to receive(:new).and_return(sidekiq_retries)
      described_class.new.perform

      expect(Raven).to have_received(:capture_exception).with(
        described_class::SidekiqRetriesQueueHigh.new(
          'Sidekiq pending retries depth is high (100). Suggests high error rate',
        ),
      )
    end

    it 'doesn’t alert when the sidekiq retries queue is low' do
      sidekiq_retries = instance_double(Sidekiq::RetrySet, size: 20)
      allow(Sidekiq::RetrySet).to receive(:new).and_return(sidekiq_retries)
      described_class.new.perform

      expect(Raven).not_to have_received(:capture_exception)
    end
  end
end

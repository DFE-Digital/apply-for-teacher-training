require 'rails_helper'

RSpec.describe DetectInvariantsHourlyCheck do
  before do
    allow(Sentry).to receive(:capture_exception)

    # or unwanted exceptions will be thrown by this check
    TeacherTrainingPublicAPI::SyncCheck.set_last_sync(Time.zone.now)
  end

  describe '#perform' do
    it 'detects unauthorised edits on data associated with an application form', :with_audited do
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

      expect(Sentry).to have_received(:capture_exception).with(
        described_class::ApplicationEditedByWrongCandidate.new(
          <<~MSG,
            The following application forms have had edits by a candidate who is not the owner of the application:

            #{HostingEnvironment.application_url}/support/applications/#{suspect_form.id}
          MSG
        ),
      )
    end

    it 'ignores withdrawn and rejected application choices submitted with the same course' do
      course = create(:course, :open)
      course_option1 = create(:course_option, course:)
      course_option2 = create(:course_option, course:)
      course_option3 = create(:course_option, course:)
      application_form = create(:completed_application_form)

      create(:application_choice, :awaiting_provider_decision, status: :withdrawn, application_form:, course_option: course_option1)
      create(:application_choice, :awaiting_provider_decision, status: :rejected, application_form:, course_option: course_option2)
      create(:application_choice, :awaiting_provider_decision, application_form:, course_option: course_option3)

      described_class.new.perform

      expect(Sentry).not_to have_received(:capture_exception)
    end

    it 'detects when the course sync hasn’t succeeded for an hour' do
      TeacherTrainingPublicAPI::SyncCheck.clear_last_sync

      described_class.new.perform

      expect(Sentry).to have_received(:capture_exception).with(
        described_class::CourseSyncNotSucceededForAnHour.new(
          'The course sync via the Teacher training public API has not succeeded for an hour',
        ),
      )
    end

    it 'doesn’t alert when the course sync has succeeded recently' do
      described_class.new.perform

      expect(Sentry).not_to have_received(:capture_exception)
    end

    context 'when HostingEnvironment is review' do
      it 'doesn’t check API sync on review apps' do
        allow(HostingEnvironment).to receive(:review?).and_return(true)
        allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:check)

        described_class.new.perform

        expect(TeacherTrainingPublicAPI::SyncCheck).not_to have_received(:check)
        expect(Sentry).not_to have_received(:capture_exception)
      end
    end

    context 'when HostingEnvironment is not review' do
      it 'check API sync on not on review apps' do
        allow(HostingEnvironment).to receive(:review?).and_return(false)
        allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:check)

        described_class.new.perform

        expect(TeacherTrainingPublicAPI::SyncCheck).to have_received(:check)
        expect(Sentry).to have_received(:capture_exception)
      end
    end
  end
end

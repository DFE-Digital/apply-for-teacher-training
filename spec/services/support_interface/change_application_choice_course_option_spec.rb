require 'rails_helper'

RSpec.describe SupportInterface::ChangeApplicationChoiceCourseOption do
  describe '#call' do
    let!(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
    let(:course) { create(:course) }
    let!(:course_option) { create(:course_option, study_mode: :full_time, course: course) }
    let(:other_provider) { create(:provider) }
    let(:audit_comment) { 'Zendesk ticket 2 - update course' }
    let(:other_site) { create(:site) }

    it 'sets the course_option of the specified site of a course' do
      expect {
        described_class.new(application_choice_id: application_choice.id,
                            provider_id: course_option.course.provider_id,
                            course_code: course_option.course.code,
                            study_mode: course_option.study_mode,
                            site_code: course_option.site.code,
                            audit_comment: '').call
      }.to(change { application_choice.reload.course_option })

      expect(application_choice.course_option).to eq(course_option)
    end

    it 'creates an audit entry', :with_audited do
      expect {
        described_class.new(application_choice_id: application_choice.id,
                            provider_id: course_option.course.provider_id,
                            course_code: course_option.course.code,
                            study_mode: course_option.study_mode,
                            site_code: course_option.site.code,
                            audit_comment:).call
      }.to change { Audited::Audit.count }.by(1)

      expect(Audited::Audit.last.comment).to eq(audit_comment)
    end

    it 'raises a RecordNotFound error if the course does not exist for the provided provider_id' do
      expect {
        described_class.new(application_choice_id: application_choice.id,
                            provider_id: other_provider.id,
                            course_code: course_option.course.code,
                            study_mode: course_option.study_mode,
                            site_code: course_option.site.code,
                            audit_comment:).call
      }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Course/)
    end

    it 'raises a RecordNotFound error if the site does not exist for the provided course' do
      expect {
        described_class.new(application_choice_id: application_choice.id,
                            provider_id: course_option.course.provider_id,
                            course_code: course_option.course.code,
                            study_mode: course_option.study_mode,
                            site_code: other_site.code,
                            audit_comment:).call
      }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find CourseOption/)
    end

    it 'raises a RecordNotFound error if the site does not exist for the provided study_mode' do
      expect {
        described_class.new(application_choice_id: application_choice.id,
                            provider_id: course_option.course.provider_id,
                            course_code: course_option.course.code,
                            study_mode: :part_time,
                            site_code: course_option.site.code,
                            audit_comment:).call
      }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find CourseOption/)
    end

    context 'course is in a previous cycle' do
      let(:course) { create(:course, recruitment_cycle_year: 2024) }

      it 'sets the course_option of the specified site of a course' do
        expect {
          described_class.new(application_choice_id: application_choice.id,
                              provider_id: course_option.course.provider_id,
                              course_code: course_option.course.code,
                              study_mode: course_option.study_mode,
                              site_code: course_option.site.code,
                              recruitment_cycle_year: 2024,
                              audit_comment: '').call
        }.to(change { application_choice.reload.course_option })

        expect(application_choice.course_option).to eq(course_option)
      end
    end

    context 'application is not in a state visible to providers' do
      let!(:application_choice) { create(:application_choice, :cancelled) }

      it 'raises an application state error' do
        expect {
          described_class.new(application_choice_id: application_choice.id,
                              provider_id: course_option.course.provider_id,
                              course_code: course_option.course.code,
                              study_mode: :part_time,
                              site_code: course_option.site.code,
                              audit_comment:).call
        }.to raise_error(SupportInterface::ApplicationStateError, "Changing the course option of application choices in the #{application_choice.status} state is not allowed")
      end
    end

    context 'application is in a state visible to providers' do
      let!(:application_choice) { create(:application_choice, :offer) }

      it "doesn't raise an error" do
        expect {
          described_class.new(application_choice_id: application_choice.id,
                              provider_id: course_option.course.provider_id,
                              course_code: course_option.course.code,
                              study_mode: course_option.study_mode,
                              site_code: course_option.site.code,
                              audit_comment: '').call
        }.not_to raise_error
      end
    end

    context 'application choice interviewing providers check' do
      let!(:application_choice) { create(:application_choice, :interviewing) }

      it 'raises an error if the provider is not on the interview' do
        expect {
          described_class.new(application_choice_id: application_choice.id,
                              provider_id: other_provider.id,
                              course_code: course_option.course.code,
                              study_mode: course_option.course.study_mode,
                              site_code: course_option.site.code,
                              audit_comment:).call
        }.to raise_error(ProviderInterviewError, 'Changing a course choice when the provider is not on the interview is not allowed')
      end
    end

    context 'course full check' do
      it 'raises a CourseFullError if the new course has no vacancies' do
        course_option = create(:course_option, :no_vacancies, course: course)
        error_message = I18n.t('support_interface.errors.messages.course_full_error')

        expect {
          described_class.new(application_choice_id: application_choice.id,
                              provider_id: course_option.course.provider_id,
                              course_code: course_option.course.code,
                              study_mode: course_option.course.study_mode,
                              site_code: course_option.site.code,
                              audit_comment:).call
        }.to raise_error(CourseFullError, error_message)
      end

      it 'does not raise a CourseFullError if confirm_course_change is true' do
        course_option =  create(:course_option, :no_vacancies, course: course)

        expect {
          described_class.new(application_choice_id: application_choice.id,
                              provider_id: course_option.course.provider_id,
                              course_code: course_option.course.code,
                              study_mode: course_option.course.study_mode,
                              site_code: course_option.site.code,
                              audit_comment:,
                              confirm_course_change: 'true').call
        }.not_to raise_error
      end
    end
  end
end

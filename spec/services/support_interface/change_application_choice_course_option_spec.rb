require 'rails_helper'

RSpec.describe SupportInterface::ChangeApplicationChoiceCourseOption do
  describe '#call' do
    let!(:application_choice) { create(:application_choice, :interviewing) }
    let!(:course_option) { create(:course_option, study_mode: :full_time) }
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

    it 'creates an audit entry', with_audited: true do
      expect {
        described_class.new(application_choice_id: application_choice.id,
                            provider_id: course_option.course.provider_id,
                            course_code: course_option.course.code,
                            study_mode: course_option.study_mode,
                            site_code: course_option.site.code,
                            audit_comment: audit_comment).call
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
                            audit_comment: audit_comment).call
      }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find Course/)
    end

    it 'raises a RecordNotFound error if the site does not exist for the provided course' do
      expect {
        described_class.new(application_choice_id: application_choice.id,
                            provider_id: course_option.course.provider_id,
                            course_code: course_option.course.code,
                            study_mode: course_option.study_mode,
                            site_code: other_site.code,
                            audit_comment: audit_comment).call
      }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find CourseOption/)
    end

    it 'raises a RecordNotFound error if the site does not exist for the provided study_mode' do
      expect {
        described_class.new(application_choice_id: application_choice.id,
                            provider_id: course_option.course.provider_id,
                            course_code: course_option.course.code,
                            study_mode: :part_time,
                            site_code: course_option.site.code,
                            audit_comment: audit_comment).call
      }.to raise_error(ActiveRecord::RecordNotFound, /Couldn't find CourseOption/)
    end

    context 'application choice status check' do
      let!(:application_choice) { create(:application_choice, :offer) }

      it 'raises an error if the application is not in a decision pending state' do
        expect {
          described_class.new(application_choice_id: application_choice.id,
                              provider_id: course_option.course.provider_id,
                              course_code: course_option.course.code,
                              study_mode: :part_time,
                              site_code: course_option.site.code,
                              audit_comment: audit_comment).call
        }.to raise_error(RuntimeError, "Changing the course option of application choices in the #{application_choice.status} state is not allowed")
      end
    end
  end
end

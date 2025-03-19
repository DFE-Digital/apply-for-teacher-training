require 'rails_helper'

RSpec.describe DataMigrations::RemoveCoursesNotOnPublish do
  include TeacherTrainingPublicAPIHelper

  let!(:provider) { create(:provider) }
  let!(:second_provider) { create(:provider) }
  let!(:course_existing_in_apply_but_not_publish) { create(:course, :uuid, provider:) }
  let!(:course_existing_in_apply_and_publish) { create(:course, :uuid, provider:) }
  let!(:course_existing_in_apply_but_not_publish_with_choices) { create(:application_choice, course_option: create(:course_option, course: create(:course, :uuid, provider:))).current_course }

  before do
    stub_teacher_training_api_courses(
      provider_code: provider.code,
      recruitment_cycle_year: current_year,
      specified_attributes: [
        { code: course_existing_in_apply_and_publish.code, uuid: course_existing_in_apply_and_publish.uuid },
      ],
    )

    stub_teacher_training_api_courses_404(provider_code: second_provider.code, recruitment_cycle_year: current_year)
  end

  it 'deletes courses not in publish' do
    described_class.new.change

    expect(Course.all).not_to include(course_existing_in_apply_but_not_publish)
  end

  it 'keeps courses not in publish when there are applications for the course' do
    described_class.new.change

    expect(Course.all).to include(course_existing_in_apply_but_not_publish_with_choices)
  end

  it 'keeps courses that are in both publish and apply' do
    described_class.new.change

    expect(Course.all).to include(course_existing_in_apply_and_publish)
  end
end

require 'rails_helper'

RSpec.describe DataMigrations::BackfillCurrentCourseOptionId do
  it 'uses offered_course_option_id, if present' do
    course_option = create(:course_option)
    application_choice = create(:application_choice, offered_course_option_id: course_option.id)

    described_class.new.change

    expect(application_choice.reload.current_course_option_id).to eq(course_option.id)
  end

  it 'falls back to course_option_id, if offered_course_option_id is blank' do
    application_choice = create(:application_choice, offered_course_option_id: nil)
    application_choice.update_columns(current_course_option_id: nil)

    described_class.new.change

    expect(application_choice.reload.current_course_option_id).to eq(application_choice.course_option.id)
  end
end

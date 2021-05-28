require 'rails_helper'

RSpec.describe DataMigrations::RemovePreviousCyclesCoursesFromApplicationsInTheCurrentCycle do
  it 'removes course choices from the previous cycle from application forms in the current cycle', with_audited: true do
    application_form = create(:application_form)
    course_from_previous_cycle = create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year)
    course_from_current_cycle = create(:course, recruitment_cycle_year: RecruitmentCycle.current_year)

    old_course_option = create(:course_option, course: course_from_previous_cycle)
    new_course_option = create(:course_option, course: course_from_current_cycle)

    invalid_application_choice = create(:application_choice, course_option: old_course_option, application_form: application_form)
    valid_application_choice = create(:application_choice, course_option: new_course_option, application_form: application_form)

    described_class.new.change

    expect(application_form.reload.application_choices).to eq [valid_application_choice]
    expect(application_form.audits.last.comment).to eq "Application_choice ##{invalid_application_choice.id} was deleted due to being associated with a course from last years recruitment cycle"
  end
end

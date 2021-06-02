require 'rails_helper'

RSpec.describe DataMigrations::RemoveApplicationChoiceInTheIncorrectCycle do
  it 'removes course choices from the previous cycle from application forms in the current cycle', with_audited: true do
    application_form_from_current_cycle = create(:application_form)
    application_form_from_previous_cycle = create(:application_form, recruitment_cycle_year: RecruitmentCycle.previous_year)

    course_from_previous_cycle = create(:course, recruitment_cycle_year: RecruitmentCycle.previous_year)
    course_from_current_cycle = create(:course, recruitment_cycle_year: RecruitmentCycle.current_year)

    old_course_option = create(:course_option, course: course_from_previous_cycle)
    new_course_option = create(:course_option, course: course_from_current_cycle)

    invalid_application_choice1 = create(:application_choice, course_option: old_course_option, application_form: application_form_from_current_cycle)
    valid_application_choice1 = create(:application_choice, course_option: new_course_option, application_form: application_form_from_current_cycle)

    invalid_application_choice2 = create(:application_choice, course_option: new_course_option, application_form: application_form_from_previous_cycle)
    valid_application_choice2 = create(:application_choice, course_option: old_course_option, application_form: application_form_from_previous_cycle)

    described_class.new.change

    expect(application_form_from_current_cycle.reload.application_choices).to match_array [valid_application_choice1]
    expect(application_form_from_current_cycle.audits.last.comment).to eq "Application_choice ##{invalid_application_choice1.id} was deleted due to being associated with a course from another recruitment cycle"
    expect(application_form_from_previous_cycle.reload.application_choices).to match_array [valid_application_choice2]
    expect(application_form_from_previous_cycle.audits.last.comment).to eq "Application_choice ##{invalid_application_choice2.id} was deleted due to being associated with a course from another recruitment cycle"
  end
end

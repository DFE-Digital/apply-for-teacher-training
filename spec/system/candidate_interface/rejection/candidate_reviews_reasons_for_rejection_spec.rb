require 'rails_helper'

RSpec.feature 'Candidate can see their structured reasons for rejection when reviewing their application', continuous_applications: false, time: CycleTimetableHelper.mid_cycle do
  scenario 'when a candidate visits their apply again application form they can see apply1 rejection reasons' do
    given_i_am_signed_in

    and_i_have_an_apply1_application_with_rejections

    when_i_visit_my_application_complete_page
    then_i_can_see_my_rejection_reasons

    when_i_apply_again
    then_i_can_see_rejection_reasons_from_the_earlier_application
    and_i_should_see_unsuccessful_status
    and_i_should_not_see_a_link_to_the_course_on_find
    and_i_should_see_application_with_unstructured_feedback
    and_i_should_not_see_application_without_feedback
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_apply1_application_with_rejections
    travel_temporarily_to(mid_cycle(CycleTimetable.previous_year)) do
      @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
      @application_choice_with_feedback = create(:application_choice, :with_old_structured_rejection_reasons, application_form: @application_form)
      @application_choice_with_unstructured_feedback = create(:application_choice, :rejected, application_form: @application_form, rejection_reason: 'Disappointing')
      @application_choice_without_feedback = create(:application_choice, :rejected, application_form: @application_form, rejection_reason: nil)
    end
  end

  def when_i_visit_my_application_complete_page
    visit candidate_interface_application_complete_path
  end

  def then_i_can_see_my_rejection_reasons
    expect(page).to have_content('Quality of application')
    expect(page).to have_content('Use a spellchecker')
  end

  def when_i_apply_again
    click_link_or_button 'Apply again'
  end

  def then_i_can_see_rejection_reasons_from_the_earlier_application
    expect(page).to have_content('Quality of application')
    expect(page).to have_content('Use a spellchecker')
  end

  def and_i_should_see_unsuccessful_status
    expect(page).to have_content('Unsuccessful')
  end

  def and_i_should_not_see_a_link_to_the_course_on_find
    course_name = @application_choice_with_feedback.current_course.name_and_code
    expect(page).to have_content(course_name)
    expect(page).to have_no_link(course_name)
  end

  def and_i_should_see_application_with_unstructured_feedback
    course_name = @application_choice_with_unstructured_feedback.current_course.name_and_code
    expect(page).to have_content(course_name)
    expect(page).to have_content(@application_choice_with_unstructured_feedback.rejection_reason)
  end

  def and_i_should_not_see_application_without_feedback
    course_name = @application_choice_without_feedback.current_course.name_and_code
    expect(page).to have_no_content(course_name)
  end
end

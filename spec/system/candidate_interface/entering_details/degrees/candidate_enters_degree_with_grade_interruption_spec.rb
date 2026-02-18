require 'rails_helper'

RSpec.describe 'Entering a degree', :js do
  include CandidateHelper
  include CandidateEnteringDegreesHelper

  scenario 'Candidate enters their degree with degree grade interruption' do
    given_i_am_signed_in_with_one_login
    and_i_have_application_choices_in_draft
    when_i_view_the_degree_section

    and_i_answer_that_i_have_a_university_degree

    # Add country
    then_i_can_see_the_country_page
    when_i_choose_united_kingdom
    and_i_click_on_save_and_continue

    # Add degree level
    then_i_can_see_the_level_page
    when_i_choose_the_level
    and_i_click_on_save_and_continue

    # Add degree type
    then_i_can_see_the_type_page
    when_i_choose_the_type_of_degree
    and_i_click_on_save_and_continue

    # Add subject
    then_i_can_see_the_subject_page
    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue

    # Add university
    then_i_can_see_the_university_page
    when_i_fill_in_the_university
    and_i_click_on_save_and_continue

    # Add completion
    then_i_can_see_the_completion_page
    when_i_choose_whether_degree_is_completed
    and_i_click_on_save_and_continue

    # Add a low grade
    then_i_can_see_the_grade_page
    when_i_select_the_grade_is_a_third_class
    and_i_click_on_save_and_continue

    # Add start year
    then_i_can_see_the_start_year_page
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    # Add award year
    then_i_can_see_the_award_year_page
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue

    # Grade interruption
    then_i_see_the_grade_interruption_page_referring_to_one_or_more_draft_applications
    and_i_click_on_continue_to_save_this_degree

    # Review
    then_i_can_check_my_undergraduate_degree
    and_the_completed_section_radios_are_not_selected

    # Edit a step
    when_i_click_the_grade_change_link_and_press_save_and_continue
    then_i_see_the_grade_interruption_page_referring_to_one_or_more_draft_applications
    and_i_click_on_continue_to_save_this_degree

    # Delete a choice
    when_i_delete_one_of_my_choices
    and_i_click_the_grade_change_link_and_press_save_and_continue
    then_i_see_the_grade_interruption_page_referring_to_one_draft_application
    click_on 'Continue to save this degree'

    # Change degree grade to predicted
    when_i_update_the_degree_grade_to_predicted
    and_i_click_the_grade_change_link_and_press_save_and_continue
    then_i_see_the_degrees_review_page_and_no_interruption
  end
end

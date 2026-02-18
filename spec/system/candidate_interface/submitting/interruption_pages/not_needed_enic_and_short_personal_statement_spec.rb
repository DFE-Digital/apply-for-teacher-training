require 'rails_helper'

RSpec.describe 'Candidate submits the application with interruption pages' do
  include CandidateHelper
  include CandidateInterruptionPagesHelper

  scenario 'Candidate submits an application with all applications having an enic_reason of not_needed and personal statement less than 500 words', :js, time: mid_cycle do
    given_i_am_signed_in_with_one_login

    when_i_have_completed_my_application_and_have_added_primary_as_a_course_choice_with_not_needed_qualification
    and_i_continue_with_my_application

    when_i_save_as_draft
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted
    and_i_continue_with_my_application

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_personal_statement
    when_i_continue_without_editing
    then_i_see_a_interruption_page_for_not_needed_enic
    then_the_viewed_enic_interruption_page_cookie_to_be_set
  end
end

require 'rails_helper'

RSpec.describe 'Candidate submits the application with interruption pages' do
  include CandidateHelper
  include CandidateInterruptionPagesHelper

  scenario 'Candidate submits a teacher degree apprenticeship course having a degree with long personal statement and with ENIC', :js, time: mid_cycle do
    given_i_am_signed_in_with_one_login

    when_i_have_completed_application_to_primary_course_choice_with_long_personal_statement
    and_i_have_a_degree
    and_course_choice_is_undergraduate
    and_i_continue_with_my_application

    when_i_save_as_draft
    and_i_am_redirected_to_the_application_dashboard
    and_my_application_is_still_unsubmitted
    and_i_continue_with_my_application

    when_i_click_to_review_my_application
    then_i_see_a_interruption_page_for_degree_warning
    when_i_click_to_continue_and_apply_for_the_course
    then_i_see_the_review_and_submit_page
  end
end

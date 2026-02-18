require 'rails_helper'

RSpec.describe 'Candidate submits the application with interruption pages' do
  include CandidateHelper
  include CandidateInterruptionPagesHelper

  scenario 'Candidate submits an application for a course whose required grade is higher than their highest recorded undergrad degree grade', time: mid_cycle do
    given_i_am_signed_in_with_one_login
    and_i_have_one_application_in_draft

    when_i_visit_my_applications
    and_i_click('Gorse SCITT')

    when_i_click_to_review_my_application
    then_i_see_an_interruption_page_for_incompatible_grade

    when_i_click('Continue to submit this application')
    then_i_see_the_review_and_submit_page
  end
end

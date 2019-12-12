require 'rails_helper'

RSpec.feature 'Referee submits a reference for a candidate', sidekiq: true do
  include CandidateHelper

  scenario 'Candidate with a completed application' do
    FeatureFlag.activate('training_with_a_disability')

    given_a_candidate_completed_an_application
    # and_selected_me_as_a_referee
    when_the_candidate_submits_the_application
    then_i_receive_an_email_with_a_magic_link
  end

  def given_a_candidate_completed_an_application
    candidate_completes_application_form
  end

  def when_the_candidate_submits_the_application
    candidate_submits_application
  end

  def then_i_receive_an_email_with_a_magic_link
    open_email('terri@example.com')

    current_email.click_link candidate_interface_reference_comments_url(token: '1234567890')
  end
end

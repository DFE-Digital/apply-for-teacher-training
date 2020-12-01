require 'rails_helper'

RSpec.describe 'Candidate providing feedback on Find' do
  scenario 'Candidate arrives from Find and provides feedback' do
    given_i_arrive_from_find_with_valid_params_in_the_query_string
    and_the_find_feedback_flag_is_active

    when_i_complete_and_submit_the_feedback_form
    then_i_am_thanked_for_my_feedback
  end

  def given_i_arrive_from_find_with_valid_params_in_the_query_string
    visit candidate_interface_find_feedback_path(original_controller: 'courses', path: '/course/T92/X130')
  end

  def and_the_find_feedback_flag_is_active
    FeatureFlag.activate('find_feedback')
  end

  def when_i_complete_and_submit_the_feedback_form
    fill_in 'How can we improve this service?', with: 'Make it better.'
    fill_in 'Email address (optional)', with: 'email@gmail.com'

    click_button 'Submit feedback'
  end

  def then_i_am_thanked_for_my_feedback
    expect(page).to have_content 'Thank you for your feedback'
  end
end

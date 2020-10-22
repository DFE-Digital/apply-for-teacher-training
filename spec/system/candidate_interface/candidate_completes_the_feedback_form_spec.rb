require 'rails_helper'

RSpec.describe 'Candidate feedback form' do
  include CandidateHelper

  before do 
    FeatureFlag.activate(:feedback_form)
    FeatureFlag.activate(:decoupled_references)
  end

  scenario 'Candidate completes the feedback form' do
    given_the_candidate_completes_and_submits_their_application
    then_they_should_be_asked_to_give_feedback

    when_they_click_give_feedback
    then_they_should_see_the_feedback_form

    when_i_choose_very_satisfied
    and_i_make_a_suggestion
    and_click_send_feedback
    then_i_see_the_thank_you_page
    and_my_feedback_should_reflect_my_inputs
  end

  def given_the_candidate_completes_and_submits_their_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def then_they_should_be_asked_to_give_feedback
    expect(page).to have_content('Your feedback will help us improve.')
  end

  def when_they_click_give_feedback
    click_link 'Give feedback'
  end

  def then_they_should_see_the_feedback_form
    expect(page).to have_content(t('page_titles.your_feedback'))
  end

  def when_i_choose_1
    choose 'Very satisfied'
  end

  def and_i_make_a_suggestion
    fill_in 'How could we improve this service?', with: 'More rainbows and unicorns'
  end

  def and_click_send_feedback
    click_button 'Send feedback'
  end

  def then_i_see_the_thank_you_page
    expect(page).to have_content(t('page_titles.thank_you'))
  end

  def and_my_feedback_should_reflect_my_inputs
    expect(ApplicationForm.last.feedback_satisfaction_level).to eq('very_satisfied')
  end
end

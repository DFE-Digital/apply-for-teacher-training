require 'rails_helper'

RSpec.describe 'Candidate satisfaction survey' do
  include CandidateHelper

  scenario 'Candidate completes the survey' do
    given_the_satisfaction_survey_flag_is_active
    and_the_training_with_a_disability_flag_is_active

    when_the_candidate_completes_and_submits_their_application
    then_they_should_be_asked_to_give_feedback

    when_they_click_give_feedback
    then_they_should_see_the_recommendation_page

    when_i_choose_1
    and_click_continue
    then_i_see_the_complexity_page

  end

  def given_the_satisfaction_survey_flag_is_active
    FeatureFlag.activate('satisfaction_survey')
  end

  def and_the_training_with_a_disability_flag_is_active
    FeatureFlag.activate('training_with_a_disability')
  end

  def when_the_candidate_completes_and_submits_their_application
    candidate_completes_application_form
    candidate_submits_application
  end

  def then_they_should_be_asked_to_give_feedback
    expect(page).to have_content('Your feedback will help us improve.')
  end

  def when_they_click_give_feedback
    click_link 'Give feedback'
  end

  def then_they_should_see_the_recommendation_page
    expect(page).to have_content(t('page_titles.recommendation'))
  end

  def when_i_choose_1
    choose '1 - strongly agree'
  end

  def and_click_continue
    click_button 'Continue'
  end

  def then_i_see_the_complexity_page
    expect(page).to have_content(t('page_titles.complexity'))
  end
end

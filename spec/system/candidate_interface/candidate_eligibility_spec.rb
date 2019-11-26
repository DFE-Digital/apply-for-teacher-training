require 'rails_helper'

RSpec.feature 'Candidate eligibility' do
  scenario 'Candidate confirms that they are eligible' do
    given_the_pilot_is_open

    when_i_click_start_on_the_start_page
    and_i_press_continue
    then_i_see_validation_errors
    and_i_answer_no_to_some_questions
    then_i_should_be_redirected_to_ucas

    when_i_click_start_on_the_start_page
    when_i_answer_yes_to_all_questions
    then_should_be_redirected_to_the_signup_page
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def when_i_click_start_on_the_start_page
    visit '/'
    click_on t('application_form.begin_button')
  end

  def and_i_press_continue
    click_on 'Continue'
  end

  def then_i_see_validation_errors
    expect(page).to have_content 'Select if you are a citizen of the UK, EU or EEA'
  end

  def and_i_answer_no_to_some_questions
    within_fieldset('Are you a citizen of the UK, EU or EEA?') do
      choose 'No'
    end

    within_fieldset('Did you gain all your qualifications at institutions based in the UK?') do
      choose 'Yes'
    end

    click_on 'Continue'
  end

  def then_i_should_be_redirected_to_ucas
    expect(page).to have_content 'We’re sorry, but we’re not ready for you yet'
  end

  def when_i_answer_yes_to_all_questions
    within_fieldset('Are you a citizen of the UK, EU or EEA?') do
      choose 'Yes'
    end

    within_fieldset('Did you gain all your qualifications at institutions based in the UK?') do
      choose 'Yes'
    end

    click_on 'Continue'
  end

  def then_should_be_redirected_to_the_signup_page
    expect(page).to have_content 'Create an Apply for teacher training account'
  end
end

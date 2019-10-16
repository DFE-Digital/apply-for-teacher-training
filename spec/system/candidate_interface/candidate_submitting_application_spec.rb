require 'rails_helper'

RSpec.feature 'Candidate submit the application' do
  scenario 'Candidate with personal details' do
    given_i_am_signed_in
    and_i_filled_in_personal_details_and_review_my_application

    and_i_confirm_my_application

    then_i_can_see_the_submit_application_page
    # then_i_can_submit_my_application
  end

  def then_i_can_see_the_submit_application_page
    expect(page).to have_content 'Submit application'
  end

  def and_i_confirm_my_application
    click_link 'Continue'
  end

  def and_i_filled_in_personal_details_and_review_my_application
    and_i_filled_in_personal_details
    and_i_visit_the_application_form_page
    when_i_click_on_check_your_answers
  end

  def when_i_click_on_check_your_answers
    click_link 'Check your answers before submitting'
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def given_i_am_signed_in
    candidate = create(:candidate)
    login_as(candidate)
  end

  def then_i_can_review_my_application
    expect(page).to have_content 'Review your application'
  end

  def and_i_filled_in_personal_details
    scope = 'application_form.personal_details'
    visit candidate_interface_personal_details_edit_path

    fill_in t('first_name.label', scope: scope), with: 'Lando'
    fill_in t('last_name.label', scope: scope), with: 'Calrissian'

    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'

    select('British', from: t('nationality.label', scope: scope))
    find('details').click
    within('details') do
      select('American', from: t('second_nationality.label', scope: scope))
    end

    choose 'Yes'
    fill_in t('english_main_language.yes_label', scope: scope), with: "I'm great at Galactic Basic so English is a piece of cake", match: :prefer_exact

    click_button t('complete_form_button', scope: scope)
  end

  def then_i_can_see_the_personal_my_details
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content '6 April 1937'
    expect(page).to have_content 'British and American'
    expect(page).to have_content "I'm great at Galactic Basic so English is a piece of cake"
  end
end

require 'rails_helper'

RSpec.describe 'Candidate updates their english proficiency no qualification details' do
  include CandidateHelper

  before do
    Feature.find_or_create_by(name: 'application_form_has_many_english_proficiencies', active: true)
  end

  after do
    FeatureFlag.deactivate(:application_form_has_many_english_proficiencies)
  end

  scenario do
    given_i_am_signed_in_with_one_login
    and_english_is_not_my_first_language
    and_i_have_previous_entered_my_english_proficiency
    and_visit_my_details
    when_i_click_on_english_as_a_foreign_language
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_degree_taught_in_english_with_details

    when_i_click_on_change_plan_to_take_an_efl_assessment
    then_i_see_the_may_need_to_an_efl_assessment_page
    and_i_see_yes_selected
    and_i_see_the_details_of_my_efl_assessment

    when_i_click_on_back
    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_degree_taught_in_english_with_details

    when_i_click_change_plan_to_take_an_efl_assessment_details
    then_i_see_the_may_need_to_an_efl_assessment_page
    and_i_see_yes_selected
    and_i_see_the_details_of_my_efl_assessment

    when_i_select_no
    and_i_click_on_continue
    and_i_see_that_my_level_of_english_is_degree_taught_in_english_with_no_details

    when_i_click_on_change_plan_to_take_an_efl_assessment
    then_i_see_the_may_need_to_an_efl_assessment_page_for_the_updated_english_proficiency

    when_i_select_yes
    and_i_enter_the_details_of_my_assessment
    and_i_click_on_continue

    then_i_see_the_review_page
    and_i_see_that_my_level_of_english_is_degree_taught_in_english_with_details
  end

private

  def and_english_is_not_my_first_language
    @application_form = create(
      :application_form,
      :international_address,
      first_nationality: 'American',
      candidate: current_candidate,
    )
  end

  def and_i_have_previous_entered_my_english_proficiency
    @efl_qualification = create(:toefl_qualification)
    @english_proficiency = create(
      :english_proficiency,
      application_form: @application_form,
      degree_taught_in_english: true,
      no_qualification_details: 'Work in progress',
    )
  end

  def and_visit_my_details
    visit candidate_interface_details_path
  end

  def when_i_click_on_english_as_a_foreign_language
    click_on 'English as a foreign language'
  end

  def then_i_see_the_review_page
    expect(page).to have_current_path candidate_interface_english_proficiencies_review_path
    expect(page).to have_element(:h1, text: 'Check your English as a foreign language assessment', class: 'govuk-heading-xl')
  end

  def and_i_see_that_my_level_of_english_is_degree_taught_in_english_with_details
    within('.govuk-summary-card') do
      expect(page).to have_element(:h2, text: 'English as a foreign language assessment', class: 'govuk-summary-card__title')
      expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'My degree was taught in English', class: 'govuk-summary-list__value')
      expect(page).to have_element(
        :dt,
        text: 'Do you plan on taking an English as a foreign language assessment?',
        class: 'govuk-summary-list__key',
      )
      expect(page).to have_element(:dd, text: 'Yes', class: 'govuk-summary-list__value')
      expect(page).to have_element(
        :dt,
        text: 'Details',
        class: 'govuk-summary-list__key',
      )
      expect(page).to have_element(:dd, text: 'Work in progress', class: 'govuk-summary-list__value')
    end
  end

  def when_i_click_on_change_plan_to_take_an_efl_assessment
    click_on 'Change plan to take an English as a foreign language assessment'
  end

  def then_i_see_the_may_need_to_an_efl_assessment_page
    expect(page).to have_current_path(candidate_interface_english_proficiencies_no_qualification_details_path(@english_proficiency), ignore_query: true)
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'You may need an English as a foreign language assessment', class: 'govuk-fieldset__heading')

    expect(page).to have_field('Yes', type: 'radio')
    expect(page).to have_field('No', type: 'radio')
  end

  def then_i_see_the_may_need_to_an_efl_assessment_page_for_the_updated_english_proficiency
    english_proficiency = @application_form.english_proficiency
    expect(page).to have_current_path(candidate_interface_english_proficiencies_no_qualification_details_path(english_proficiency), ignore_query: true)
    expect(page).to have_element(:span, text: 'English as a foreign language assessment', class: 'govuk-caption-xl')
    expect(page).to have_element(:h1, text: 'You may need an English as a foreign language assessment', class: 'govuk-fieldset__heading')

    expect(page).to have_field('Yes', type: 'radio')
    expect(page).to have_field('No', type: 'radio')
  end

  def and_i_see_yes_selected
    expect(page).to have_checked_field('Yes')
  end

  def and_i_see_the_details_of_my_efl_assessment
    expect(page).to have_field('Give details of when and what type of assessment you plan to take', text: 'Work in progress')
  end

  def when_i_click_on_back
    click_on 'Back'
  end

  def and_i_click_on_continue
    click_on 'Continue'
  end

  def when_i_click_change_plan_to_take_an_efl_assessment_details
    click_on 'Change plan to take an English as a foreign language assessment details'
  end

  def and_i_see_that_my_level_of_english_is_degree_taught_in_english_with_no_details
    within('.govuk-summary-card') do
      expect(page).to have_element(:h2, text: 'English as a foreign language assessment', class: 'govuk-summary-card__title')
      expect(page).to have_element(:dt, text: 'Proving your level of English', class: 'govuk-summary-list__key')
      expect(page).to have_element(:dd, text: 'My degree was taught in English', class: 'govuk-summary-list__value')
      expect(page).to have_element(
        :dt,
        text: 'Do you plan on taking an English as a foreign language assessment?',
        class: 'govuk-summary-list__key',
      )
      expect(page).to have_element(:dd, text: 'No', class: 'govuk-summary-list__value')
    end
  end

  def when_i_select_no
    choose 'No'
  end

  def when_i_select_yes
    choose 'Yes'
  end

  def and_i_enter_the_details_of_my_assessment
    fill_in 'Give details of when and what type of assessment you plan to take', with: 'Work in progress'
  end
end

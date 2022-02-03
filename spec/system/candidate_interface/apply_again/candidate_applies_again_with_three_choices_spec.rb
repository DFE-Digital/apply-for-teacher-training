require 'rails_helper'

RSpec.feature 'Apply again with three choices' do
  include CandidateHelper

  scenario 'Candidate applies again with three choices' do
    given_the_apply_again_with_three_courses_feature_flag_is_active
    and_i_am_signed_in_as_a_candidate
    when_i_have_an_unsuccessful_application
    and_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    then_i_should_see_text_suggesting_that_i_can_apply_to_three_courses
    then_i_can_select_a_course
    then_i_should_see_text_suggesting_that_i_can_add_two_more_courses
    and_i_add_two_more_courses
    then_i_can_see_my_application_with_three_courses
  end

  def given_the_apply_again_with_three_courses_feature_flag_is_active
    FeatureFlag.activate(:apply_again_with_three_choices)
  end

  def and_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsuccessful_application
    @application_form = create(
      :completed_application_form,
      candidate: @candidate,
    )
    create(:application_choice, status: :rejected, application_form: @application_form)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Apply again'
  end

  def then_i_should_see_text_suggesting_that_i_can_apply_to_three_courses
    expect(page).to have_content('You can apply for up to 3 courses.')
  end

  def then_i_can_select_a_course
    click_link 'Choose your courses', exact: true
    given_courses_exist

    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Primary (2XT2)'
    click_button t('continue')
  end

  def then_i_should_see_text_suggesting_that_i_can_add_two_more_courses
    expect(page).to have_content('You can choose 2 more courses')
  end

  def and_i_add_two_more_courses
    choose 'Yes, add another course'
    click_button t('continue')
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
    choose 'Drama (2397)'
    click_button t('continue')

    choose 'Yes, add another course'
    click_button t('continue')
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
    choose 'English (6Z9H)'
    click_button t('continue')
  end

  def then_i_can_see_my_application_with_three_courses
    expect(page).to have_content('Primary (2XT2)')
    expect(page).to have_content('Drama (2397)')
    expect(page).to have_content('English (6Z9H)')
  end
end

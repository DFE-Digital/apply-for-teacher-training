require 'rails_helper'

RSpec.feature 'Candidate arrives from Find with provider and course params', continuous_applications: false do
  include CandidateHelper

  scenario 'The candidate cannot add course twice with back button' do
    given_i_am_signed_in

    # Single site course
    and_i_have_less_than_3_application_options
    and_the_course_i_selected_only_has_one_site
    when_i_arrive_at_the_apply_from_find_page_with_the_single_site_course_params
    when_i_say_yes
    then_i_should_see_the_courses_review_page
    and_i_expect_to_have_one_application_choice_for_this_course

    when_i_click_the_back_button

    then_i_should_see_the_confirm_selection_page
    when_i_say_yes
    then_i_should_see_the_courses_review_page
    and_i_expect_to_have_one_application_choice_for_this_course
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_less_than_3_application_options
    application_form = create(:application_form, candidate: @candidate)
    create(:application_choice, application_form:)
  end

  def and_the_course_i_selected_only_has_one_site
    @course = create(:course, :open_on_apply, name: 'Potions')
    @site = create(:site, provider: @course.provider)
    create(:course_option, site: @site, course: @course)
  end

  def when_i_arrive_at_the_apply_from_find_page_with_the_single_site_course_params
    visit candidate_interface_apply_from_find_path(
      providerCode: @course.provider.code,
      courseCode: @course.code,
    )
  end

  def when_i_say_yes
    choose 'Yes'
    click_button t('continue')
  end

  def then_i_should_see_the_courses_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_expect_to_have_one_application_choice_for_this_course
    expect(page).to have_css('.app-summary-card__header', text: 'Potions', count: 1)
  end

  def when_i_click_the_back_button
    visit candidate_interface_course_confirm_selection_path(@course.id)
  end

  def then_i_should_see_the_confirm_selection_page
    expect(page).to have_current_path(candidate_interface_course_confirm_selection_path(@course.id))
  end
end

require 'rails_helper'

RSpec.feature 'Entering their degrees' do
  include CandidateHelper

  scenario 'Candidate submits their degrees' do
    given_i_am_not_signed_in
    and_i_visit_the_degrees_page
    then_i_see_the_homepage

    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_degree
    then_i_see_the_undergraduate_degree_form

    when_i_fill_in_some_of_my_undergraduate_degree_but_omit_some_required_details
    and_i_submit_the_undergraduate_degree_form
    then_i_see_validation_errors_for_my_undergraduate_degree

    when_i_fill_in_my_undergraduate_degree
    and_i_submit_the_undergraduate_degree_form
    then_i_can_check_my_undergraduate_degree

    when_i_click_on_continue
    then_i_should_see_the_form_and_the_section_is_not_completed
    when_i_click_on_degree
    then_i_can_check_my_undergraduate_degree

    when_i_click_on_add_another_degree
    then_i_see_the_add_another_degree_form

    when_i_fill_in_my_additional_degree
    and_i_submit_the_add_another_degree_form
    then_i_can_check_my_additional_degree

    when_i_click_on_delete_degree
    and_i_confirm_that_i_want_to_delete_my_additional_degree
    then_i_can_only_see_my_undergraduate_degree

    when_i_click_to_change_my_undergraduate_degree
    then_i_see_my_undergraduate_degree_filled_in

    when_i_change_my_undergraduate_degree
    and_i_submit_the_undergraduate_degree_form
    then_i_can_check_my_revised_undergraduate_degree

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_degree
    then_i_can_check_my_answers
  end

  def given_i_am_not_signed_in; end

  def and_i_visit_the_degrees_page
    visit candidate_interface_degrees_new_base_path
  end

  def then_i_see_the_homepage
    expect(page).to have_current_path(candidate_interface_start_path)
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_degree
    click_link t('page_titles.degree')
  end

  def then_i_see_the_undergraduate_degree_form
    expect(page).to have_content(t('page_titles.add_undergraduate_degree'))
  end

  def when_i_fill_in_some_of_my_undergraduate_degree_but_omit_some_required_details
    fill_in t('application_form.degree.qualification_type.label'), with: 'BSc'
    fill_in t('application_form.degree.subject.label'), with: 'Computer Science'
  end

  def and_i_submit_the_undergraduate_degree_form
    click_button t('application_form.degree.base.button')
  end

  def then_i_see_validation_errors_for_my_undergraduate_degree
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/degree_form.attributes.institution_name.blank')
  end

  def when_i_fill_in_my_undergraduate_degree
    fill_in t('application_form.degree.qualification_type.label'), with: 'BA'
    fill_in t('application_form.degree.subject.label'), with: 'Doge'
    fill_in t('application_form.degree.institution_name.label'), with: 'University of Much Wow'

    choose t('application_form.degree.grade.first.label')

    fill_in t('application_form.degree.award_year.label'), with: '2009'
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_content t('application_form.degree.qualification.label')
    expect(page).to have_content 'BA Doge'
  end

  def when_i_click_on_continue
    click_button t('application_form.degree.review.button')
  end

  def then_i_should_see_the_form_and_the_section_is_not_completed
    expect(page).to have_content(t('page_titles.application_form'))
    expect(page).not_to have_css('#degrees-completed', text: 'Completed')
  end

  def when_i_click_on_add_another_degree
    click_link t('application_form.degree.another.button')
  end

  def then_i_see_the_add_another_degree_form
    expect(page).to have_content(t('page_titles.add_another_degree'))
  end

  def when_i_fill_in_my_additional_degree
    fill_in t('application_form.degree.qualification_type.label'), with: 'Masters'
    fill_in t('application_form.degree.subject.label'), with: 'Cate'
    fill_in t('application_form.degree.institution_name.label'), with: 'University of Much Wow'

    choose t('application_form.degree.grade.upper_second.label')

    fill_in t('application_form.degree.award_year.label'), with: '2011'
  end

  def and_i_submit_the_add_another_degree_form
    click_button t('application_form.degree.base.button')
  end

  def then_i_can_check_my_additional_degree
    expect(page).to have_content 'Masters Cate'
  end

  def when_i_click_on_delete_degree
    click_link(t('application_form.degree.delete'), match: :first)
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_degree
    click_button t('application_form.degree.confirm_delete')
  end

  def then_i_can_only_see_my_undergraduate_degree
    then_i_can_check_my_undergraduate_degree
    expect(page).not_to have_content 'Masters Cate'
  end

  def when_i_click_to_change_my_undergraduate_degree
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def then_i_see_my_undergraduate_degree_filled_in
    expect(page).to have_selector("input[value='BA']")
    expect(page).to have_selector("input[value='Doge']")
    expect(page).to have_selector("input[value='University of Much Wow']")
    expect(page).to have_selector("input[value='first']")
    expect(page).to have_selector("input[value='2009']")
  end

  def when_i_change_my_undergraduate_degree
    fill_in t('application_form.degree.subject.label'), with: 'Wolf'
    fill_in t('application_form.degree.institution_name.label'), with: 'University of Moon Moon'
  end

  def then_i_can_check_my_revised_undergraduate_degree
    expect(page).to have_content 'BA Wolf'
    expect(page).to have_content 'University of Moon Moon'
  end

  def when_i_mark_this_section_as_completed
    check t('application_form.degree.review.completed_checkbox')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#degrees-completed', text: 'Completed')
  end

  def then_i_can_check_my_answers
    then_i_can_check_my_revised_undergraduate_degree
  end
end

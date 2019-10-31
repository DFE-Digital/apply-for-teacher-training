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

    when_i_click_on_add_another_degree
    then_i_see_the_add_another_degree_form

    when_i_fill_in_my_additional_degree
    and_i_submit_the_add_another_degree_form
    then_i_can_check_my_additional_degree
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
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/degrees_form.attributes.institution_name.blank')
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
end

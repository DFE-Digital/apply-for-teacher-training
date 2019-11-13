require 'rails_helper'

RSpec.feature 'Entering volunteering and school experience' do
  include CandidateHelper

  scenario 'Candidate submits their volunteering and school experience' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_volunteering_with_children_and_young_people
    then_i_am_asked_if_i_have_experience_volunteering_with_young_people_or_in_school

    when_i_choose_yes_experience
    and_i_submit_the_volunteering_experience_form
    then_i_see_the_add_volunteering_role_form

    when_i_fill_in_some_of_my_role_but_omit_some_required_details
    and_i_submit_the_volunteering_role_form
    then_i_see_validation_errors_for_my_volunteering_role

    when_i_fill_in_my_volunteering_role
    and_i_submit_the_volunteering_role_form
    then_i_check_my_volunteering_role

    when_i_delete_my_volunteering_role
    and_i_confirm
    then_i_no_longer_see_my_volunteering_role
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_volunteering_with_children_and_young_people
    click_link t('page_titles.volunteering.short')
  end

  def then_i_am_asked_if_i_have_experience_volunteering_with_young_people_or_in_school
    expect(page).to have_content(t('application_form.volunteering.experience.label'))
  end

  def when_i_choose_yes_experience
    choose 'Yes'
  end

  def and_i_submit_the_volunteering_experience_form
    click_button t('application_form.volunteering.experience.button')
  end

  def then_i_see_the_add_volunteering_role_form
    expect(page).to have_content(t('page_titles.add_volunteering_role'))
  end

  def when_i_fill_in_some_of_my_role_but_omit_some_required_details
    fill_in t('application_form.volunteering.role.label'), with: 'Classroom Volunteer'
    fill_in t('application_form.volunteering.organisation.label'), with: 'A Noice School'
  end

  def and_i_submit_the_volunteering_role_form
    click_button t('application_form.volunteering.complete_form_button')
  end

  def then_i_see_validation_errors_for_my_volunteering_role
    expect(page).to have_content t('activemodel.errors.models.candidate_interface/volunteering_role_form.attributes.start_date.invalid')
  end

  def when_i_fill_in_my_volunteering_role
    fill_in t('application_form.volunteering.role.label'), with: 'Classroom Volunteer'
    fill_in t('application_form.volunteering.organisation.label'), with: 'A Noice School'

    choose 'Yes'

    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '5'
      fill_in 'Year', with: '2018'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '1'
      fill_in 'Year', with: '2019'
    end

    fill_in t('application_form.volunteering.details.label'), with: 'I volunteered.'
  end

  def then_i_check_my_volunteering_role
    expect(page).to have_content('Classroom Volunteer')
  end

  def when_i_delete_my_volunteering_role
    click_link t('application_form.volunteering.delete')
  end

  def and_i_confirm
    click_button t('application_form.volunteering.confirm_delete')
  end

  def then_i_no_longer_see_my_volunteering_role
    expect(page).not_to have_content('Classroom Volunteer')
  end
end

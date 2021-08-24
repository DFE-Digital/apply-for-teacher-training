require 'rails_helper'

RSpec.feature 'Entering volunteering and school experience' do
  include CandidateHelper

  scenario 'Candidate submits their volunteering and school experience' do
    given_i_am_signed_in
    and_the_restructured_work_history_flag_is_off
    and_i_visit_the_site

    when_i_click_on_volunteering_with_children_and_young_people
    then_i_am_asked_if_i_have_experience_volunteering_with_young_people_or_in_school

    when_i_choose_yes_experience
    and_i_submit_the_volunteering_experience_form
    then_i_see_the_add_volunteering_role_form

    when_i_fill_in_some_of_my_role_but_omit_some_required_details
    and_i_submit_the_volunteering_role_form
    then_i_see_validation_errors_for_my_volunteering_role
    and_i_see_the_incorrect_values

    when_i_fill_in_my_volunteering_role
    and_i_submit_the_volunteering_role_form
    then_i_check_my_volunteering_role
    and_i_mark_the_section_as_complete
    and_i_click_on_continue
    then_i_should_see_the_form

    when_i_click_on_volunteering_with_children_and_young_people
    then_i_can_check_my_answers

    when_i_click_on_add_another_role
    then_i_see_the_add_volunteering_role_form

    when_i_click_back
    and_i_delete_my_volunteering_role
    and_i_confirm
    then_i_am_asked_if_i_have_experience_volunteering_with_young_people_or_in_school

    when_i_choose_no_experience
    and_i_submit_the_volunteering_experience_form
    then_i_can_see_a_link_to_get_school_experience

    when_i_click_on_change
    then_i_see_the_unpaid_experience_page

    when_i_choose_yes_experience
    and_i_submit_the_volunteering_experience_form
    then_i_see_the_add_volunteering_role_form

    when_i_fill_in_another_volunteering_role
    and_i_submit_the_volunteering_role_form
    then_i_check_my_volunteering_role

    when_i_click_to_change_my_volunteering_role
    then_i_see_my_volunteering_role_filled_in

    when_i_change_my_volunteering_role
    and_i_submit_the_volunteering_role_form
    then_i_can_check_my_revised_volunteering_role

    when_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_i_should_see_the_form
    and_that_the_section_is_completed

    when_i_click_on_volunteering_with_children_and_young_people
    then_i_can_check_my_answers
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_restructured_work_history_flag_is_off
    FeatureFlag.deactivate('restructured_work_history')
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
    click_button t('save_and_continue')
  end

  def then_i_see_the_add_volunteering_role_form
    expect(page).to have_content(t('page_titles.add_volunteering_role'))
  end

  def when_i_fill_in_some_of_my_role_but_omit_some_required_details
    fill_in t('application_form.volunteering.role.label'), with: 'Classroom Volunteer'
    fill_in t('application_form.volunteering.organisation.label'), with: 'A Noice School'
    within('[data-qa="start-date"]') do
      fill_in 'Month', with: '33'
      fill_in 'Year', with: '2010'
    end

    within('[data-qa="end-date"]') do
      fill_in 'Month', with: '11'
      fill_in 'Year', with: '9999'
    end
  end

  def and_i_mark_the_section_as_complete
    choose t('application_form.completed_radio')
  end

  def and_i_submit_the_volunteering_role_form
    click_button t('save_and_continue')
  end

  def then_i_see_validation_errors_for_my_volunteering_role
    expect(page).to have_content t('errors.messages.invalid_date', article: 'a', attribute: 'start date')
    expect(page).to have_content t('errors.messages.invalid_date', article: 'an', attribute: 'end date')
  end

  def and_i_see_the_incorrect_values
    within('[data-qa="start-date"]') do
      expect(find_field('Month').value).to eq('33')
    end

    within('[data-qa="end-date"]') do
      expect(find_field('Year').value).to eq('9999')
    end
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
    expect(current_candidate.current_application.application_volunteering_experiences.count).to eq 1
  end

  def and_i_click_on_continue
    click_button t('continue')
  end

  def and_i_delete_my_volunteering_role
    click_link t('application_form.volunteering.delete.action')
  end

  def and_i_confirm
    click_button t('application_form.volunteering.delete.confirm')
  end

  def then_i_no_longer_see_my_volunteering_role
    expect(page).not_to have_content('Classroom Volunteer')
  end

  def when_i_click_add_another_role
    click_link t('application_form.volunteering.another.button')
  end

  def when_i_fill_in_another_volunteering_role
    when_i_fill_in_my_volunteering_role
  end

  def when_i_click_to_change_my_volunteering_role
    click_change_link('role')
  end

  def then_i_see_my_volunteering_role_filled_in
    expect(page).to have_selector("input[value='Classroom Volunteer']")
    expect(page).to have_selector("input[value='A Noice School']")
    expect(page).to have_selector("input[value='true']")
    expect(page).to have_selector("input[value='5']")
    expect(page).to have_selector("input[value='2018']")
    expect(page).to have_selector("input[value='1']")
    expect(page).to have_selector("input[value='2019']")
  end

  def when_i_change_my_volunteering_role
    fill_in t('application_form.volunteering.organisation.label'), with: 'Much Wow School'
  end

  def then_i_can_check_my_revised_volunteering_role
    expect(page).to have_content 'Much Wow School'
  end

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_click_on_continue
    click_button t('continue')
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#unpaid-experience-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_answers
    then_i_check_my_volunteering_role
  end

  def when_i_click_on_add_another_role
    click_link t('application_form.volunteering.another.button')
  end

  def then_i_see_the_unpaid_experience_page
    expect(page).to have_content(t('page_titles.volunteering.long'))
  end

  def then_i_see_the_add_volunteering_role_form
    expect(page).to have_content(t('page_titles.add_volunteering_role'))
  end

  def when_i_click_back
    click_link 'Back'
  end

  def when_i_choose_no_experience
    choose 'No'
  end

  def then_i_can_see_a_link_to_get_school_experience
    expect(page).to have_link(
      t('application_form.volunteering.no_experience.get_experience'),
      href: 'https://getintoteaching.education.gov.uk/get-school-experience',
    )
  end

  def when_i_click_on_change
    click_link t('application_form.volunteering.experience.change_action')
  end
end

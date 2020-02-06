require 'rails_helper'

RSpec.feature 'A candidate edits their course choice after submission' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Time.zone.local(2019, 12, 16)) do
      example.run
    end
  end

  scenario 'candidate deletes their course choice and add a new one', sidekiq: true do
    given_the_edit_application_feature_flag_is_on
    and_i_am_signed_in_as_a_candidate
    and_i_have_a_completed_application

    when_i_visit_the_application_dashboard
    and_i_click_the_edit_link
    then_i_see_a_button_to_edit_my_application

    when_i_click_the_edit_button
    then_i_see_the_edit_application_page

    when_i_click_course_choices
    then_i_can_delete_my_course_choices

    when_i_click_the_delete_course_link
    then_i_see_the_delete_confirmation_page

    when_i_click_the_confirm_button
    then_i_see_that_the_course_choice_is_deleted

    given_there_are_course_options
    when_i_add_a_new_course_choice
    then_i_see_the_new_course_choice
  end

  def given_the_edit_application_feature_flag_is_on
    FeatureFlag.activate('edit_application')
  end

  def and_i_am_signed_in_as_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_have_a_completed_application
    form = create(:completed_application_form, :with_completed_references, candidate: current_candidate, submitted_at: Time.zone.local(2019, 12, 16))
    @application_choice = create(:application_choice, status: :awaiting_references, edit_by: Time.zone.local(2019, 12, 20), application_form: form)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_the_edit_link
    click_link t('application_complete.dashboard.edit_link')
  end

  def then_i_see_a_button_to_edit_my_application
    expect(page).to have_link(t('application_complete.edit_page.edit_button'))
  end

  def when_i_click_the_edit_button
    click_link t('application_complete.edit_page.edit_button')
  end

  def then_i_see_the_edit_application_page
    within('.govuk-heading-xl') do
      expect(page).to have_content(t('page_titles.edit_application_form'))
    end
  end

  def when_i_click_course_choices
    click_link t('page_titles.course_choices')
  end

  def then_i_can_delete_my_course_choices
    expect(page).to have_link t('application_form.courses.delete')
  end

  def when_i_click_the_delete_course_link
    click_link t('application_form.courses.delete')
  end

  def then_i_see_the_delete_confirmation_page
    expect(page).to have_content(t('page_titles.destroy_course_choice'))
  end

  def when_i_click_the_confirm_button
    click_button t('application_form.courses.confirm_delete')
  end

  def then_i_see_that_the_course_choice_is_deleted
    expect(page).not_to have_content(@application_choice.provider.name)
    expect(page).not_to have_content(@application_choice.course_option.course.name)
    expect(page).not_to have_content(@application_choice.course_option.site.name)
  end

  def when_i_add_a_new_course_choice
    click_link 'Continue'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
    select 'Gorse SCITT (1N1)'
    click_button 'Continue'
    select 'Primary (2XT2)'
    click_button 'Continue'
    choose 'Main site'
    click_button 'Continue'
  end

  def then_i_see_the_new_course_choice
    expect(page).to have_content('Gorse SCITT')
    expect(page).to have_content('Primary (2XT2)')
    expect(page).to have_content('Main site')
    expect(page).to have_content('Gorse SCITT, C/O The Bruntcliffe Academy, Bruntcliffe Lane, MORLEY, lEEDS, LS27 0LZ')
  end

  def given_there_are_course_options
    provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    first_site = create(
      :site, name: 'Main site',
      code: '-',
      provider: provider,
      address_line1: 'Gorse SCITT',
      address_line2: 'C/O The Bruntcliffe Academy',
      address_line3: 'Bruntcliffe Lane',
      address_line4: 'MORLEY, lEEDS',
      postcode: 'LS27 0LZ'
    )
    second_site = create(
      :site, name: 'Harehills Primary School',
      code: '1',
      provider: provider,
      address_line1: 'Darfield Road',
      address_line2: '',
      address_line3: 'Leeds',
      address_line4: 'West Yorkshire',
      postcode: 'LS8 5DQ'
    )
    multi_site_course = create(:course, name: 'Primary', code: '2XT2', provider: provider, exposed_in_find: true, open_on_apply: true)
    create(:course_option, site: first_site, course: multi_site_course, vacancy_status: 'B')
    create(:course_option, site: second_site, course: multi_site_course, vacancy_status: 'B')

    another_provider = create(:provider, name: 'Royal Academy of Dance', code: 'R55')
    third_site = create(
      :site, name: 'Main site',
      code: '-',
      provider: another_provider,
      address_line1: 'Royal Academy of Dance',
      address_line2: '36 Battersea Square',
      address_line3: '',
      address_line4: 'London',
      postcode: 'SW11 3RA'
    )
    single_site_course = create(:course, name: 'Dance', code: 'W5X1', provider: another_provider, exposed_in_find: true, open_on_apply: true)
    create(:course_option, site: third_site, course: single_site_course, vacancy_status: 'B')
  end
end

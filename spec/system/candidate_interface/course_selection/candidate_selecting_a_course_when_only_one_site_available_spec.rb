require 'rails_helper'

RSpec.feature 'Selecting a course when only a single site is available' do
  include CandidateHelper

  scenario 'Candidate selects a course choice' do
    given_i_am_signed_in
    and_there_are_course_options

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_click_on_add_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    then_i_should_see_a_course_and_its_description

    and_i_choose_a_course
    and_i_choose_not_to_add_another_course
    then_i_am_on_the_course_choices_page
    and_i_see_my_completed_course_choice
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    first_site = create(
      :site,
      name: 'Main site',
      code: '-',
      provider: @provider,
      address_line1: 'Gorse SCITT',
      address_line2: 'C/O The Bruntcliffe Academy',
      address_line3: 'Bruntcliffe Lane',
      address_line4: 'MORLEY, lEEDS',
      postcode: 'LS27 0LZ',
    )
    second_site = create(
      :site,
      name: 'Harehills Primary School',
      code: '1',
      provider: @provider,
      address_line1: 'Darfield Road',
      address_line2: '',
      address_line3: 'Leeds',
      address_line4: 'West Yorkshire',
      postcode: 'LS8 5DQ',
    )
    third_site = create(
      :site,
      name: 'Rabbitvale Primary School',
      code: '2',
      provider: @provider,
      address_line1: 'Garfield Road',
      address_line2: '',
      address_line3: 'Leeds',
      address_line4: 'West Yorkshire',
      postcode: 'LS8 5DP',
    )
    @course = create(
      :course,
      name: 'Primary',
      code: '2XT2',
      provider: @provider,
      exposed_in_find: true,
      open_on_apply: true,
    )
    create(
      :course_option,
      site: first_site,
      course: @course,
      vacancy_status: :no_vacancies,
      site_still_valid: true,
    )
    create(
      :course_option,
      site: second_site,
      course: @course,
      vacancy_status: :vacancies,
      site_still_valid: true,
    )
    create(
      :course_option,
      site: third_site,
      course: @course,
      vacancy_status: :vacancies,
      site_still_valid: false,
    )
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link 'Choose your courses'
  end

  def and_i_click_on_add_course
    click_link t('continue')
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
  end

  def and_i_choose_a_provider
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
  end

  def then_i_should_see_a_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description)
  end

  def and_i_choose_a_course
    choose 'Primary (2XT2)'
    click_button t('continue')
  end

  def and_i_choose_not_to_add_another_course
    choose 'No, not at the moment'
    click_button t('continue')
  end

  def then_i_am_on_the_course_choices_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_see_my_completed_course_choice
    expect(page).to have_content('Gorse SCITT')
    expect(page).to have_content('Primary (2XT2)')
    expect(page).to have_content('Harehills Primary School')
  end
end

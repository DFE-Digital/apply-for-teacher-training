require 'rails_helper'

RSpec.feature 'Selecting a course' do
  include CandidateHelper

  scenario 'Candidate selects a course choice' do
    given_i_am_signed_in
    and_there_are_course_options

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_click_on_add_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider

    when_submit_without_choosing_a_course
    then_i_should_see_an_error

    and_i_choose_a_course
    then_i_see_the_address
    and_i_choose_a_location
    then_i_see_my_completed_course_choice

    # attempt to add the same course
    when_i_click_on_add_another_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    and_i_choose_a_course
    then_i_see_a_message_that_ive_already_chosen_the_course

    given_that_i_am_on_the_course_choices_review_page
    when_i_click_on_add_another_course
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_another_provider

    when_i_click_back
    and_i_choose_another_course_with_only_one_site
    then_i_review_my_second_course_choice

    when_i_mark_this_section_as_completed
    when_i_click_continue
    then_i_see_that_the_section_is_completed

    and_i_click_on_course_choices
    and_i_delete_one_of_my_course_choice
    and_i_confirm_that_i_want_to_delete_my_choice
    then_i_no_longer_see_my_course_choice
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_are_course_options
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

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link 'Course choices'
  end

  def and_i_click_on_add_course
    click_link 'Continue'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'
  end

  def and_i_choose_a_provider
    choose 'Gorse SCITT (1N1)'
    click_button 'Continue'
  end

  def when_submit_without_choosing_a_course
    click_button 'Continue'
  end

  def then_i_should_see_an_error
    expect(page).to have_content 'Select a course'
  end

  def and_i_choose_a_course
    choose 'Primary (2XT2)'
    click_button 'Continue'
  end

  def then_i_see_the_address
    expect(page).to have_content('Gorse SCITT, C/O The Bruntcliffe Academy, Bruntcliffe Lane, MORLEY, lEEDS, LS27 0LZ')
  end

  def and_i_choose_a_location
    choose 'Main site'
    click_button 'Continue'
  end

  def then_i_see_my_completed_course_choice
    expect(page).to have_content('Gorse SCITT')
    expect(page).to have_content('Primary (2XT2)')
    expect(page).to have_content('Main site')
    expect(page).to have_content('Gorse SCITT, C/O The Bruntcliffe Academy, Bruntcliffe Lane, MORLEY, lEEDS, LS27 0LZ')
  end

  def when_i_click_on_add_another_course
    click_link 'Add another course'
  end

  def then_i_see_a_message_that_ive_already_chosen_the_course
    expect(page).to have_css('.govuk-error-summary', text: 'You have already selected this course')
  end

  def given_that_i_am_on_the_course_choices_review_page
    visit candidate_interface_course_choices_review_path
  end

  def and_i_choose_another_provider
    choose 'Royal Academy of Dance (R55)'
    click_button 'Continue'
  end

  def and_i_choose_another_course_with_only_one_site
    choose 'Dance (W5X1)'
    click_button 'Continue'
  end

  def then_i_review_my_second_course_choice
    expect(page).to have_content('Royal Academy of Dance')
    expect(page).to have_content('Dance (W5X1)')
    expect(page).to have_content('Main site')
    expect(page).to have_content('Royal Academy of Dance, 36 Battersea Square, London, SW11 3RA')
  end

  def when_i_mark_this_section_as_completed
    visit candidate_interface_course_choices_index_path
    check t('application_form.courses.complete.completed_checkbox')
  end

  def then_i_see_that_the_section_is_completed
    expect(page).to have_css('#course-choices-badge-id', text: 'Completed')
  end

  def when_i_click_continue
    click_button 'Continue'
  end

  def when_i_click_back
    # TODO: the back link goes back to the '/candidate/application/courses/provider' instead of going back to the specific provider.
    # Fix this and use click_link 'Back'

    visit '/candidate/application/courses/provider/R55/courses'
  end

  def and_i_delete_one_of_my_course_choice
    first(:link, t('application_form.courses.delete')).click
  end

  def and_i_confirm_that_i_want_to_delete_my_choice
    click_button t('application_form.courses.confirm_delete')
  end

  def then_i_no_longer_see_my_course_choice
    expect(page).not_to have_content('Primary (2XT2)')
  end
end

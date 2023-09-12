require 'rails_helper'

RSpec.feature 'Selecting a course', :continuous_applications do
  include CandidateHelper

  it 'Candidate selects a course choice' do
    given_i_am_signed_in
    and_there_are_course_options

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_click_continue
    then_i_should_see_an_error_message_about_to_select_if_i_know_which_course

    and_i_choose_that_i_know_where_i_want_to_apply

    and_i_click_continue
    then_i_should_see_an_error_message_about_to_select_provider
    and_i_choose_a_provider
    then_i_should_see_a_course_and_its_description

    when_submit_without_choosing_a_course
    then_i_should_see_an_error
    and_i_choose_a_course
    then_i_should_be_on_the_application_choice_review_page
    and_i_click_the_back_button
    then_i_should_be_on_the_application_choices_page

    given_the_provider_has_over_twenty_courses
    and_i_click_on_course_choices
    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    then_the_course_choices_should_be_a_dropdown
    and_the_select_box_has_no_value_selected
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(
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
    @course = create(:course, :open_on_apply, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site:, course: @course)
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link 'Your application'
    click_link 'Add application'
  end

  def then_i_should_see_an_error_message_about_to_select_if_i_know_which_course
    expect(page).to have_content('Select if you have chosen a course or not')
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    and_i_click_continue
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_that_i_know_where_i_want_to_apply
  end

  def then_i_should_see_an_error_message_about_to_select_provider
    within('.govuk-error-summary') do
      expect(page).to have_content('There is a problem')
      expect(page).to have_content('Select a training provider')
    end
  end

  def and_i_choose_a_provider
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
  end

  def then_i_should_see_a_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description)
  end

  def when_submit_without_choosing_a_course
    click_button t('continue')
  end

  def then_i_should_see_an_error
    expect(page).to have_content 'Select a course'
  end

  def and_i_choose_a_course
    choose 'Primary (2XT2)'
    click_button t('continue')
  end

  def when_i_click_continue
    click_button t('continue')
  end

  def and_i_click_continue
    when_i_click_continue
  end

  def given_the_provider_has_over_twenty_courses
    create_list(:course, 20, provider: @provider, exposed_in_find: true)
  end

  def then_the_course_choices_should_be_a_dropdown
    expect(page.find('select#which-course-are-you-applying-to-course-id-field')).to be_present
  end

  def and_the_select_box_has_no_value_selected
    expect(find_by_id('which-course-are-you-applying-to-course-id-field').value).to eq ''
  end

  def and_i_click_the_back_button
    click_link 'Back to your applications'
  end

  def and_i_see_my_course_choices
    within("#course-choice-#{application_choice.id}") do
      expect(page).to have_content('Primary (2XT2)')
    end
  end

  def then_i_should_be_on_the_application_choices_page
    expect(page.current_url).to end_with(candidate_interface_continuous_applications_choices_path)
  end
end

require 'rails_helper'

RSpec.describe 'Selecting a course' do
  include CandidateHelper

  it 'Candidate selects a course choice' do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_click_continue
    then_i_see_an_error_message_about_to_select_if_i_know_which_course

    and_i_choose_that_i_know_where_i_want_to_apply

    and_i_click_continue
    then_i_see_an_error_message_about_to_select_provider
    and_i_choose_a_provider
    then_i_see_a_course_and_its_description

    and_i_click_the_back_link
    then_i_see_the_provider_chosen_selected
    and_i_click_continue
    then_i_see_the_provider_name_in_caption

    when_submit_without_choosing_a_course
    then_i_see_an_error
    and_i_choose_a_course
    then_i_am_on_the_application_choice_review_page
    and_i_click_the_back_button
    then_i_am_on_the_application_choices_page
    and_i_see_my_course_choices

    when_the_course_is_full
    when_i_visit_the_course_choices_page
    when_i_click_to_view_my_application
    then_i_see_that_the_course_is_unavailable
    and_i_can_change_the_course

    given_the_provider_has_over_twenty_courses
    and_i_click_on_course_choices
    when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    then_i_see_the_provider_name_in_caption
    then_the_course_choices_am_a_dropdown
    and_the_select_box_has_no_value_selected
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
    @course = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, site:, course: @course)
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_i_click_on_course_choices
    click_link_or_button 'Your application'
    click_link_or_button 'Add application'
  end

  def then_i_see_an_error_message_about_to_select_if_i_know_which_course
    expect(page).to have_content('Select if you know which course you want to apply to')
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    and_i_click_continue
  end

  def when_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_that_i_know_where_i_want_to_apply
  end

  def then_i_see_an_error_message_about_to_select_provider
    within('.govuk-error-summary') do
      expect(page).to have_content('There is a problem')
      expect(page).to have_content('Select a training provider')
    end
  end

  def and_i_choose_a_provider
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
  end

  def then_i_see_a_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description_to_s)
  end

  def when_submit_without_choosing_a_course
    click_link_or_button t('continue')
  end

  def then_i_see_an_error
    expect(page).to have_content 'Select a course'
  end

  def and_i_choose_a_course
    choose 'Primary (2XT2)'
    click_link_or_button t('continue')
  end

  def when_i_click_continue
    click_link_or_button t('continue')
  end

  def and_i_click_continue
    when_i_click_continue
  end

  def given_the_provider_has_over_twenty_courses
    create_list(:course, 20, provider: @provider, exposed_in_find: true)
  end

  def then_the_course_choices_am_a_dropdown
    expect(page.find('select#which-course-are-you-applying-to-course-id-field')).to be_present
  end

  def and_the_select_box_has_no_value_selected
    expect(find_by_id('which-course-are-you-applying-to-course-id-field').value).to eq ''
  end

  def and_i_click_the_back_button
    click_link_or_button 'Back to your applications'
  end

  def and_i_see_my_course_choices
    expect(page).to have_content(application_choice.course.provider.name)
    expect(page).to have_content('Primary (2XT2)')
  end

  def then_i_am_on_the_application_choices_page
    expect(page.current_url).to end_with(candidate_interface_application_choices_path)
  end

  def when_the_course_is_full
    @course.course_options.first.update!(vacancy_status: 'no_vacancies')
  end

  def when_i_visit_the_course_choices_page
    @application_choice = current_candidate.current_application.application_choices.first
    when_i_visit_my_applications
  end

  def and_i_can_change_the_course
    click_link_or_button 'Change'
    expect(page).to have_content('Which course are you applying to?')
  end

  def and_i_click_the_back_link
    click_link_or_button 'Back'
  end

  def then_i_see_the_provider_chosen_selected
    expect(page).to have_select('Which training provider are you applying to?', selected: 'Gorse SCITT (1N1)')
  end

  def then_i_see_the_provider_name_in_caption
    expect(page.first('.govuk-caption-xl').text).to eq('Gorse SCITT')
  end
end

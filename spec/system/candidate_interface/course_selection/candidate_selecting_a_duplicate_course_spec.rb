require 'rails_helper'

RSpec.describe 'Selecting a course' do
  include CandidateHelper

  it 'Candidate selects a course they have already applied to' do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options
    and_i_have_an_application_to_a_course

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_a_provider
    then_i_see_a_course_and_its_description

    and_i_choose_a_duplicate_course
    then_i_am_on_the_application_choice_duplicate_page
    when_i_click_back
    then_i_am_on_the_course_choice_page
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, course: @course)
  end

  def then_i_am_on_the_application_choice_duplicate_page
    expect(page).to have_content('You already have an application for Primary (2XT2) at Gorse SCITT')
  end

  def and_i_have_an_application_to_a_course
    create(:application_choice, :unsubmitted, course_option: @course.course_options.first, application_form: @current_candidate.current_application)
  end

  def when_i_visit_the_site
    visit candidate_interface_details_path
  end

  def and_i_click_on_course_choices
    click_link_or_button 'Your application'
    click_link_or_button 'Add application'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')
  end

  def and_i_choose_a_provider
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
  end

  def then_i_see_a_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description_to_s)
  end

  def and_i_choose_a_duplicate_course
    choose 'Primary (2XT2)'
    click_link_or_button t('continue')
  end

  def when_i_click_back
    click_link_or_button 'Back'
  end

  def then_i_am_on_the_course_choice_page
    expect(page.current_url).to end_with(candidate_interface_course_choices_which_course_are_you_applying_to_path(provider_id: @provider.id))
  end
end

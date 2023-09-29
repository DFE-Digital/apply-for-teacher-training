require 'rails_helper'

RSpec.feature 'Selecting a course', :continuous_applications do
  include CandidateHelper

  it 'Candidate selects a course they are reapplying to' do
    given_i_am_signed_in
    and_there_is_one_course_option
    and_i_have_a_rejected_application

    when_i_visit_the_site
    and_i_click_on_course_choices
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_the_same_provider
    then_i_should_see_the_course_and_its_description

    and_i_choose_the_same_course
    then_i_should_be_on_the_application_choice_review_page
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate(candidate: current_candidate)
  end

  def and_there_is_one_course_option
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course = create(:course, :open_on_apply, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, course: @course)
  end

  def then_i_should_be_on_the_application_choice_duplicate_page
    expect(page).to have_content('You already have an application for Primary (2XT2) at Gorse SCITT')
  end

  def and_i_have_a_rejected_application
    create(:application_choice, :rejected, course_option: @course.course_options.first, application_form: current_candidate.current_application)
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_i_click_on_course_choices
    click_link 'Your application'
    click_link 'Add application'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
  end

  def and_i_choose_the_same_provider
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
  end

  def then_i_should_see_the_course_and_its_description
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description)
  end

  def and_i_choose_the_same_course
    choose 'Primary (2XT2)'
    click_button t('continue')
  end
end

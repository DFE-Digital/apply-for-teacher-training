require 'rails_helper'

RSpec.describe 'Changing a course' do
  include CandidateHelper

  it 'Candidate changes course to one they have already been rejected from twice' do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options
    and_i_have_two_rejected_applications_to_a_course

    when_i_visit_my_details_page
    and_i_add_another_application
    and_i_choose_that_i_know_where_i_want_to_apply
    and_i_choose_the_same_provider
    then_i_see_the_courses_and_their_descriptions

    when_i_choose_a_different_course
    and_i_return_to_the_course_selection_page
    and_i_choose_the_rejected_course
    then_i_am_on_the_reached_reapplication_limit_page
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    create(:course_option, course: @course)
    @another_course = create(:course, :open, name: 'Primary with Science', code: '4MM5', provider: @provider)
    create(:course_option, course: @another_course)
  end

  def and_i_have_two_rejected_applications_to_a_course
    create(:application_choice, :rejected, course_option: @course.course_options.first, application_form: @current_candidate.current_application)
    create(:application_choice, :rejected, course_option: @course.course_options.first, application_form: @current_candidate.current_application)
  end

  def and_i_choose_the_same_provider
    select 'Gorse SCITT (1N1)'
    click_link_or_button t('continue')
  end

  def and_i_add_another_application
    click_link_or_button 'Your application'
    click_link_or_button 'Add application'
  end

  def and_i_choose_that_i_know_where_i_want_to_apply
    choose 'Yes, I know where I want to apply'
    click_link_or_button t('continue')
  end

  def then_i_see_the_courses_and_their_descriptions
    expect(page).to have_content(@course.name_and_code)
    expect(page).to have_content(@course.description_to_s)
    expect(page).to have_content(@another_course.name_and_code)
    expect(page).to have_content(@another_course.description_to_s)
  end

  def when_i_choose_a_different_course
    choose 'Primary with Science (4MM5)'
    click_link_or_button t('continue')
  end

  def and_i_return_to_the_course_selection_page
    click_on 'Change'
  end

  def and_i_choose_the_rejected_course
    choose 'Primary (2XT2)'
    click_link_or_button t('continue')
  end

  def then_i_am_on_the_reached_reapplication_limit_page
    expect(page.current_url).to end_with(candidate_interface_course_choices_reached_reapplication_limit_path(provider_id: @provider.id, course_id: @course.id))
  end

  def when_i_visit_my_details_page
    visit candidate_interface_details_path
  end
end

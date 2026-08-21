require 'rails_helper'

RSpec.describe 'Selecting a course' do
  include CandidateHelper

  # Regression test for DuplicateCourseSelection to avoid ActiveRecord::RecordInvalid
  it 'Candidate selects a course they have already applied to', :with_cache do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options
    and_i_have_already_applied_to_the_course
    when_i_visit_my_applications_page
    and_i_click_on_add_application
    and_i_choose_yes
    and_i_click_continue
    and_i_select_the_provider_name
    and_i_click_continue
    and_i_select_the_course_i_already_have_an_application_for
    and_i_click_continue

    then_i_am_on_the_application_choice_duplicate_page
  end

private

  def when_i_visit_my_applications_page
    visit '/candidate/application/choices'
  end

  def and_i_click_on_add_application
    click_on 'Add application'
  end

  def and_i_choose_yes
    choose 'Yes'
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  def and_i_select_the_provider_name
    select @provider.name
  end

  def and_i_select_the_course_i_already_have_an_application_for
    choose @course.name
  end

  def and_i_have_already_applied_to_the_course
    create(
      :application_choice,
      application_form: current_candidate.current_application,
      course: @course,
    )
  end

  def then_i_am_on_the_application_choice_duplicate_page
    expect(page).to have_text('You already have an application for')
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    site = create(:site, name: 'Main site', provider: @provider)
    create(:course_option, course: @course, site:)
  end
end

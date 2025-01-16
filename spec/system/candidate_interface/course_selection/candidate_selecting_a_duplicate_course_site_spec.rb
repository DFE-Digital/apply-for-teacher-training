require 'rails_helper'

RSpec.describe 'Selecting a course', :js do
  include CandidateHelper

  # Regression test for DuplicateCourseSelection to avoid ActiveRecord::RecordInvalid
  it 'Candidate selects a course they have already applied to' do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options

    window_1 = windows.first
    window_2 = open_new_window

    # Window 1
    visit_course_selection_page
    and_i_choose_a_location

    # Window 2
    Capybara.current_session.switch_to_window window_2
    visit_course_selection_page

    and_i_choose_a_location
    and_i_click_continue
    then_i_am_on_the_application_choice_review_page

    # Window 1
    Capybara.current_session.switch_to_window window_1
    and_i_click_continue
    then_i_am_on_the_application_choice_duplicate_page
  end

  def visit_course_selection_page
    visit "/candidate/application/course-choices/provider/#{@provider.id}/courses/#{@course.id}/full_time"
  end

  def then_i_am_on_the_application_choice_duplicate_page
    expect(page).to have_content('You already have an application for')
  end

  def and_there_are_course_options
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    site = create(:site, name: 'Main site', provider: @provider)
    create(:course_option, course: @course, site:)
  end

  def and_i_choose_a_location
    choose 'Main site'
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end
end

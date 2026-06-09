require 'rails_helper'

RSpec.describe 'Selecting a course' do
  include CandidateHelper

  # Regression test for DuplicateCourseSelection to avoid ActiveRecord::RecordInvalid
  it 'Candidate selects a course they have already applied to' do
    given_i_am_signed_in_with_one_login
    and_there_are_course_options
    and_i_have_already_applied_to_the_course
    visit_course_selection_page

    then_i_am_on_the_application_choice_duplicate_page
  end

  def visit_course_selection_page
    visit "/candidate/application/course-choices/provider/#{@provider.id}/courses/#{@course.id}/full_time"
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

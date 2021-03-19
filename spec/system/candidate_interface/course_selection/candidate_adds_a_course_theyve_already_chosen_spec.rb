require 'rails_helper'

RSpec.feature 'Handling duplicate course choices' do
  include CandidateHelper

  scenario "candidate adds a course they've already chosen" do
    given_i_am_signed_in
    and_i_have_chosen_a_course
    when_i_add_that_same_course_again
    then_i_am_taken_to_the_review_page
    and_i_am_informed_that_ive_already_added_that_course
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_chosen_a_course
    course_option = create(:course_option, course: create(:course, :open_on_apply))
    @choice = create(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option,
      application_form: current_candidate.current_application,
    )
  end

  def when_i_add_that_same_course_again
    visit candidate_interface_course_choices_course_path(@choice.provider)
    choose @choice.course.name
    click_button 'Continue'
  end

  def then_i_am_taken_to_the_review_page
    expect(page).to have_current_path candidate_interface_course_choices_review_path
  end

  def and_i_am_informed_that_ive_already_added_that_course
    within '.govuk-notification-banner--info' do
      expect(page).to have_content "You have already added #{@choice.course.name_and_code}"
    end
    expect(ApplicationChoice.count).to eq 1
  end
end

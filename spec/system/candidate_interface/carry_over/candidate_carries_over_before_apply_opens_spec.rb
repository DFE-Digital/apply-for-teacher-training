require 'rails_helper'

RSpec.describe 'Carry after find opens but before apply opens' do
  include CandidateHelper

  scenario 'candidate carries over application', time: mid_cycle do
    given_i_have_an_unsubmitted_application
    and_find_has_opened_but_apply_has_not
    and_a_course_exists

    when_i_sign_in
    and_carry_over_my_application
    and_complete_my_details
    then_i_can_add_courses
    and_i_cannot_submit_my_applications
  end

private

  def given_i_have_an_unsubmitted_application
    @candidate = create(:candidate)
    create(:application_form, :unsubmitted, :with_completed_references, :eligible_for_free_school_meals, candidate: @candidate)
  end

  def and_find_has_opened_but_apply_has_not
    advance_time_to(after_find_opens(RecruitmentCycle.next_year))
  end

  def and_a_course_exists
    @course = create(:course, :open)
    create(:course_option, course: @course)
  end

  def when_i_sign_in
    login_as @candidate
    visit root_path
  end

  def and_carry_over_my_application
    click_on 'Update your details'
  end

  def and_complete_my_details
    complete_the_equality_and_diversity_section
    complete_the_references_section
  end

  def complete_the_equality_and_diversity_section
    click_on 'Equality and diversity questions'
    candidate_fills_in_diversity_information
  end

  def complete_the_references_section
    click_on 'Your details'
    click_on 'References to be requested if you accept an offer'
    choose 'Yes, I have completed this section'
    click_on 'Continue'
  end

  def then_i_can_add_courses
    click_on 'Your applications'
    click_on 'Choose a course'
    choose 'Yes, I know where I want to apply'
    click_on 'Continue'
    select @course.provider.name
    click_on 'Continue'
    choose @course.name_and_code
    click_on 'Continue'
  end

  def and_i_cannot_submit_my_applications
    expect(page).to have_content 'Draft'
    expect(page).to have_content 'This course is not yet open to applications.'
    click_on 'Your applications'
    expect(page).to have_content 'Draft'
  end
end

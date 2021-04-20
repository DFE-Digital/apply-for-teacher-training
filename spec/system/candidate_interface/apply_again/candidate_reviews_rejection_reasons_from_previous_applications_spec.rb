require 'rails_helper'

RSpec.feature 'Candidate with unsuccessful application can review rejection reasons when applying again' do
  include CandidateHelper

  scenario 'Apply again and review rejection reasons' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_an_unsuccessful_application_with_rejection_reasons
    when_i_apply_again
    then_becoming_a_teacher_needs_review
    and_i_can_review_becoming_a_teacher

    when_i_confirm_i_have_reviewed_this_section
    then_becoming_a_teacher_no_longer_needs_review
    and_i_can_set_it_back_to_unreviewed

    when_i_submit_my_application
    then_i_am_informed_that_i_have_not_reviewed_becoming_a_teacher
    and_i_can_submit_once_i_have_reviewed
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_unsuccessful_application_with_rejection_reasons
    application = create(
      :completed_application_form,
      :with_gcses,
      :with_completed_references,
      references_count: 2,
      candidate: @candidate,
    )
    create(:application_choice, :with_structured_rejection_reasons, application_form: application)
  end

  def when_i_apply_again
    given_courses_exist

    visit candidate_interface_application_complete_path
    click_on 'Apply again'

    click_link 'Choose your course'
    candidate_fills_in_apply_again_course_choice
  end

  def then_becoming_a_teacher_needs_review
    within_task_list_item('Why do you want to teach') do
      expect(page).to have_css('.govuk-tag', text: 'Review')
    end
  end

  def and_i_can_review_becoming_a_teacher
    click_link 'Why do you want to teach'
    expect(page).to have_content 'Use a spellchecker'
  end

  def when_i_confirm_i_have_reviewed_this_section
    check t('application_form.reviewed_checkbox')
    click_button t('continue')
  end

  def then_becoming_a_teacher_no_longer_needs_review
    within_task_list_item('Why do you want to teach') do
      expect(page).to have_css('.govuk-tag', text: 'Completed')
    end
  end

  def and_i_can_set_it_back_to_unreviewed
    click_link 'Why do you want to teach'
    uncheck t('application_form.reviewed_checkbox')
    click_button t('continue')
    then_becoming_a_teacher_needs_review
  end

  def when_i_submit_my_application
    click_on 'Check and submit your application'
    click_on 'Continue'
  end

  def then_i_am_informed_that_i_have_not_reviewed_becoming_a_teacher
    within becoming_a_teacher_error_container do
      expect(page).to have_content 'Personal statement not marked as reviewed'
    end
  end

  def and_i_can_submit_once_i_have_reviewed
    click_link 'Why do you want to be a teacher?'
    click_on 'Continue'
    when_i_confirm_i_have_reviewed_this_section
    click_on 'Check and submit'
    expect(page).not_to have_css becoming_a_teacher_error_container
    click_on 'Continue'
    choose 'No'
    click_on 'Continue'
    choose 'No'
    click_button 'Send application'
    click_on 'Continue'
    expect(page).to have_content 'Application successfully submitted'
  end

private

  def becoming_a_teacher_error_container
    '#incomplete-becoming_a_teacher-error'
  end
end

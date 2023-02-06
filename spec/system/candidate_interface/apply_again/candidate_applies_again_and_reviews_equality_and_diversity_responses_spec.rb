require 'rails_helper'

RSpec.feature 'Apply again', time: CycleTimetableHelper.after_apply_1_deadline do
  include CandidateHelper

  it 'Candidate applies again and reviews equality and diversity responses' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_an_unsuccessful_application_with_equality_and_diversity_responses_from_apply_1

    when_i_apply_again
    and_i_submit_my_application

    then_i_am_presented_with_my_previous_equality_and_diversity_responses_for_review
    and_i_can_submit_once_i_have_reviewed
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_unsuccessful_application_with_equality_and_diversity_responses_from_apply_1
    travel_temporarily_to(before_apply_1_deadline) do
      application_form = create(:completed_application_form, :with_equality_and_diversity_data, candidate: @candidate)
      create(:application_choice, :rejected, application_form:)
    end
  end

  def when_i_apply_again
    given_courses_exist

    visit candidate_interface_application_complete_path
    click_on 'Apply again'

    click_link 'Choose your course'
    candidate_fills_in_apply_again_with_four_course_choices
    candidate_completes_the_section

    click_link 'References to be requested if you accept an offer'
    candidate_completes_the_section
  end

  def candidate_completes_the_section
    choose 'Yes, I have completed this section'
    click_button 'Continue'
  end

  def and_i_submit_my_application
    click_on 'Check and submit your application'
    click_on t('continue')
  end

  def then_i_am_presented_with_my_previous_equality_and_diversity_responses_for_review
    expect(page).to have_content('Equality and diversity questions')
    expect(page).to have_content('Check your answers')
  end

  def and_i_can_submit_once_i_have_reviewed
    click_on t('continue')
    choose 'No'
    click_button 'Send application'

    click_on t('continue')

    expect(page).to have_content 'Application submitted'
  end

private

  def becoming_a_teacher_error_container
    '#incomplete-becoming_a_teacher-error'
  end

  def subject_knowledge_error_container
    '#incomplete-subject_knowledge-error'
  end
end

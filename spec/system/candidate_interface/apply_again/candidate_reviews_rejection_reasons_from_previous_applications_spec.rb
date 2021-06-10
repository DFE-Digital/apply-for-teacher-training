require 'rails_helper'

RSpec.feature 'Candidate with unsuccessful application can review rejection reasons when applying again' do
  include CandidateHelper

  scenario 'Apply again and review rejection reasons' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_an_unsuccessful_application_with_rejection_reasons
    when_i_apply_again
    then_subject_knowledge_needs_review
    then_becoming_a_teacher_needs_review
    and_i_can_review_subject_knowledge
    and_i_can_review_becoming_a_teacher

    when_i_confirm_i_have_reviewed_becoming_a_teacher
    then_becoming_a_teacher_no_longer_needs_review
    and_i_can_set_it_back_to_unreviewed

    when_i_submit_my_application
    then_i_am_informed_that_i_have_not_reviewed_these_sections
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
    choice = create(:application_choice, :with_structured_rejection_reasons, application_form: application)

    choice.update!(
      structured_rejection_reasons: {
        quality_of_application_subject_knowledge_what_to_improve: 'Subject knowledge needs improving',
        quality_of_application_personal_statement_what_to_improve: 'Personal statement needs improving',
      },
    )
  end

  def when_i_apply_again
    given_courses_exist

    visit candidate_interface_application_complete_path
    click_on 'Apply again'

    click_link 'Choose your course'
    candidate_fills_in_apply_again_course_choice

    if FeatureFlag.active?(:reference_selection)
      click_link 'Select your references'
      choose 'Yes, I have completed this section'
      click_button t('save_and_continue')
    end
  end

  def then_subject_knowledge_needs_review
    within_task_list_item('Your suitability to teach a subject or age group') do
      expect(page).to have_css('.govuk-tag', text: 'Review')
    end
  end

  def then_becoming_a_teacher_needs_review
    within_task_list_item('Why do you want to teach') do
      expect(page).to have_css('.govuk-tag', text: 'Review')
    end
  end

  def and_i_can_review_subject_knowledge
    click_link 'Your suitability to teach a subject or age group'
    expect(page).to have_content 'Subject knowledge needs improving'
    visit candidate_interface_application_form_path
  end

  def and_i_can_review_becoming_a_teacher
    click_link 'Why do you want to teach'
    expect(page).to have_content 'Personal statement needs improving'
    visit candidate_interface_application_form_path
  end

  def when_i_confirm_i_have_reviewed_becoming_a_teacher
    click_link 'Why do you want to teach'
    choose t('application_form.reviewed_radio')
    click_on t('continue')
  end

  def then_becoming_a_teacher_no_longer_needs_review
    within_task_list_item('Why do you want to teach') do
      expect(page).to have_css('.govuk-tag', text: 'Completed')
    end
  end

  def and_i_can_set_it_back_to_unreviewed
    click_link 'Why do you want to teach'
    choose t('application_form.incomplete_radio')
    click_button t('continue')
  end

  def when_i_submit_my_application
    click_on 'Check and submit your application'
    click_on t('continue')
  end

  def then_i_am_informed_that_i_have_not_reviewed_these_sections
    within becoming_a_teacher_error_container do
      expect(page).to have_content 'Personal statement not marked as reviewed'
    end

    within subject_knowledge_error_container do
      expect(page).to have_content 'Subject knowledge not marked as reviewed'
    end
  end

  def and_i_can_submit_once_i_have_reviewed
    click_link 'Why do you want to be a teacher'
    click_on t('continue')
    choose t('application_form.reviewed_radio')
    click_on t('continue')
    click_link 'Your suitability to teach a subject or age group'
    choose t('application_form.reviewed_radio')
    click_on t('continue')

    click_on 'Check and submit'
    expect(page).not_to have_css becoming_a_teacher_error_container
    expect(page).not_to have_css subject_knowledge_error_container
    click_on t('continue')
    choose 'No'
    click_on t('continue')
    choose 'No'
    click_on 'Send application'
    click_on t('continue')

    expect(page).to have_content 'Application successfully submitted'
  end

private

  def becoming_a_teacher_error_container
    '#incomplete-becoming_a_teacher-error'
  end

  def subject_knowledge_error_container
    '#incomplete-subject_knowledge-error'
  end
end

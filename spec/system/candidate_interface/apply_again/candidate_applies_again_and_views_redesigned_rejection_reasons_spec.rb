require 'rails_helper'

RSpec.feature 'Apply again' do
  include CandidateHelper

  it 'Candidate applies again and reviews rejection reason from previous cycle', skip: 'Revisit' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_an_unsuccessful_application_with_rejection_reasons
    when_i_apply_again
    then_subject_knowledge_needs_review
    then_becoming_a_teacher_needs_review

    when_i_review_subject_knowledge
    then_i_can_see_subject_knowledge_feedback

    when_i_review_becoming_a_teacher
    then_i_can_see_becoming_a_teacher_feedback

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
    application.application_references.update_all(selected: true)
    choice = create(:application_choice, :with_structured_rejection_reasons, application_form: application)

    reasons = choice.structured_rejection_reasons
    reasons['selected_reasons'].insert(2, { 'id' => 'teaching_knowledge', 'selected_reasons' => [
      { 'id' => 'subject_knowledge', 'details' => { 'id' => 'subject_knowledge_details', 'text' => 'Subject knowledge needs improving' } },
    ] })
    choice.update!(structured_rejection_reasons: reasons)
  end

  def when_i_apply_again
    given_courses_exist

    visit candidate_interface_application_complete_path
    click_link_or_button 'Apply again'

    click_link_or_button 'Choose your course'
    candidate_fills_in_apply_again_with_four_course_choices
    candidate_completes_the_section

    click_link_or_button 'Select 2 references'
    choose 'Yes, I have completed this section'
    click_link_or_button t('save_and_continue')
  end

  def candidate_completes_the_section
    choose 'Yes, I have completed this section'
    click_link_or_button 'Continue'
  end

  def then_subject_knowledge_needs_review
    within_task_list_item('Your suitability to teach a subject or age group') do
      expect(page).to have_css('.govuk-tag', text: 'Review')
    end
  end

  def then_becoming_a_teacher_needs_review
    within_task_list_item('Why you want to teach') do
      expect(page).to have_css('.govuk-tag', text: 'Review')
    end
  end

  def when_i_review_subject_knowledge
    click_link 'Your suitability to teach a subject or age group'
  end

  def then_i_can_see_subject_knowledge_feedback
    expect(page).to have_content 'Subject knowledge needs improving'
  end

  def when_i_review_becoming_a_teacher
    visit candidate_interface_application_form_path
    click_link_or_button 'Why you want to teach'
  end

  def then_i_can_see_becoming_a_teacher_feedback
    expect(page).to have_content 'We do not accept applications written in Old Norse.'
  end

  def when_i_confirm_i_have_reviewed_becoming_a_teacher
    visit candidate_interface_application_form_path

    click_link_or_button 'Why you want to teach'
    choose t('application_form.reviewed_radio')
    click_link_or_button t('continue')
  end

  def then_becoming_a_teacher_no_longer_needs_review
    within_task_list_item('Why you want to teach') do
      expect(page).to have_css('.govuk-tag', text: 'Completed')
    end
  end

  def and_i_can_set_it_back_to_unreviewed
    click_link_or_button 'Why you want to teach'
    choose t('application_form.incomplete_radio')
    click_link_or_button t('continue')
  end

  def when_i_submit_my_application
    click_link_or_button 'Check and submit your application'
    click_link_or_button t('continue')
  end

  def then_i_am_informed_that_i_have_not_reviewed_these_sections
    within becoming_a_teacher_error_container do
      expect(page).to have_content 'Why you want to teach not marked as reviewed'
    end

    within subject_knowledge_error_container do
      expect(page).to have_content 'Suitability to teach your subjects or age group not marked as reviewed'
    end
  end

  def and_i_can_submit_once_i_have_reviewed
    click_link_or_button 'Why do you want to be a teacher'
    click_link_or_button t('continue')
    choose t('application_form.reviewed_radio')
    click_link_or_button t('continue')
    click_link 'Your suitability to teach a subject or age group'
    choose t('application_form.reviewed_radio')
    click_button t('continue')

    click_link_or_button 'Check and submit'
    expect(page).to have_no_css becoming_a_teacher_error_container
    expect(page).to have_no_css subject_knowledge_error_container
    click_link_or_button t('continue')

    candidate_fills_in_diversity_information

    # Is there anything else you would like to tell us about your application?
    choose 'No'
    click_link_or_button 'Send application'

    click_link_or_button t('continue')

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

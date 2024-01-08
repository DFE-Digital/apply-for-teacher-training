require 'rails_helper'

RSpec.feature 'Viewing course choices' do
  include CandidateHelper

  scenario 'candidate can view pending gcse requirements and guidance for selected courses' do
    given_i_am_signed_in
    and_i_have_two_chosen_courses_with_different_pending_gcse_requirements

    when_i_add_an_english_gcse
    and_i_visit_the_course_choice_review_page
    then_i_can_view_course_choices_without_gcse_requirements

    when_i_change_the_completed_gcse_to_a_pending_gcse
    and_i_visit_the_course_choice_review_page
    then_i_can_view_course_choices_with_pending_guidance_text
    and_i_can_view_course_choices_without_equivalency_guidance_text

    when_i_change_the_pending_gcse_to_a_missing_gcse
    and_i_visit_the_course_choice_review_page
    then_i_can_view_course_choices_without_pending_guidance_text
    and_i_can_view_course_choices_with_equivalency_guidance_text
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_two_chosen_courses_with_different_pending_gcse_requirements
    course_option1 = create(:course_option, course: create(:course, :open_on_apply, accept_pending_gcse: true, accept_gcse_equivalency: false))
    course_option2 = create(:course_option, course: create(:course, :open_on_apply, accept_pending_gcse: false, accept_gcse_equivalency: true, accept_english_gcse_equivalency: true))
    @choice1 = create(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option1,
      application_form: current_candidate.current_application,
    )
    @choice2 = create(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option2,
      application_form: current_candidate.current_application,
    )
  end

  def when_i_add_an_english_gcse
    visit candidate_interface_gcse_details_new_type_path(subject: 'english')
    choose 'GCSE'
    click_link_or_button t('save_and_continue')
    check 'English (Single award)'
    within '#candidate-interface-english-gcse-grade-form-english-gcses-english-single-award-conditional' do
      fill_in 'Grade', with: 'C'
    end
    click_link_or_button t('save_and_continue')
    fill_in 'Year', with: '2008'
    click_link_or_button t('save_and_continue')
  end

  def and_i_visit_the_course_choice_review_page
    visit candidate_interface_course_choices_review_path
  end

  def then_i_can_view_course_choices_without_gcse_requirements
    within "#course-choice-#{@choice1.id}" do
      expect(page).to have_no_content('GCSE requirements')
    end

    within "#course-choice-#{@choice2.id}" do
      expect(page).to have_no_content('GCSE requirements')
    end
  end

  def then_i_can_view_course_choices_without_pending_guidance_text
    within "#course-choice-#{@choice1.id}" do
      expect(page).to have_content('GCSE requirements')
      expect(page).to have_no_content('This provider will consider candidates with pending GCSEs')
    end

    within "#course-choice-#{@choice2.id}" do
      expect(page).to have_content('GCSE requirements')
      expect(page).to have_no_content('This provider does not consider candidates with pending GCSEs')
      expect(page).to have_no_content('You said you’re currently studying for a qualification in English')
      expect(page).to have_no_content("You can:\nfind a course that does accept pending GCSEs contact the provider to see if they will still consider your application")
    end
  end

  def and_i_can_view_course_choices_without_equivalency_guidance_text
    within "#course-choice-#{@choice1.id}" do
      expect(page).to have_content('GCSE requirements')
      expect(page).to have_no_content('This provider will not accept equivalency tests')
      expect(page).to have_no_content('You said you do not have a qualification in English')
      expect(page).to have_no_content('You can:\nfind a course that does accept equivalency tests contact the provider to see if they will still consider your application')
    end

    within "#course-choice-#{@choice2.id}" do
      expect(page).to have_content('GCSE requirements')
      expect(page).to have_no_content('This provider will accept equivalency tests in English')
    end
  end

  def when_i_change_the_completed_gcse_to_a_pending_gcse
    visit candidate_interface_gcse_review_path(subject: 'english')
    click_change_link('qualification for GCSE, english')
    choose 'I do not have a qualification in English yet'
    click_link_or_button t('save_and_continue')
    click_change_link('how you expect to gain this qualification')
    choose 'Yes'
    fill_in 'Details of the qualification you’re studying for', with: 'GCSE English'
    click_link_or_button t('save_and_continue')
  end

  def then_i_can_view_course_choices_with_pending_guidance_text
    within "#course-choice-#{@choice1.id}" do
      expect(page).to have_content('GCSE requirements')
      expect(page).to have_content('This provider will consider candidates with pending GCSEs')
    end

    within "#course-choice-#{@choice2.id}" do
      expect(page).to have_content('GCSE requirements')
      expect(page).to have_content('This provider does not consider candidates with pending GCSEs')
      expect(page).to have_content('You said you’re currently studying for a qualification in English')
      expect(page).to have_content("You can:\nfind a course that does accept pending GCSEs contact the provider to see if they will still consider your application")
    end
  end

  def when_i_change_the_pending_gcse_to_a_missing_gcse
    visit candidate_interface_gcse_review_path(subject: 'english')
    click_change_link('how you expect to gain this qualification')
    choose 'No'
    click_link_or_button t('save_and_continue')
  end

  def and_i_can_view_course_choices_with_equivalency_guidance_text
    within "#course-choice-#{@choice1.id}" do
      expect(page).to have_content('GCSE requirements')
      expect(page).to have_content('This provider will not accept equivalency tests')
      expect(page).to have_content('You said you do not have a qualification in English')
      expect(page).to have_content("You can:\nfind a course that does accept equivalency tests contact the provider to see if they will still consider your application")
    end

    within "#course-choice-#{@choice2.id}" do
      expect(page).to have_content('GCSE requirements')
      expect(page).to have_content('This provider will accept equivalency tests in English')
    end
  end
end

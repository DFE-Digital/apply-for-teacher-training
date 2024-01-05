require 'rails_helper'

RSpec.feature 'Viewing course choices' do
  include CandidateHelper

  scenario 'candidate can view degree requirements and guidance for selected courses' do
    given_i_am_signed_in
    and_i_have_three_chosen_courses_with_different_requirements

    when_i_add_a_two_two_degree
    and_i_visit_the_course_choice_review_page
    then_i_can_see_course_choices_with_relevant_guidance_for_one_course

    when_i_change_my_degree_grade_to_a_pass
    and_i_visit_the_course_choice_review_page
    then_i_can_view_course_choices_with_relevant_guidance_for_all_courses
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_three_chosen_courses_with_different_requirements
    course_option1 = create(:course_option, course: create(:course, :open_on_apply, degree_grade: 'two_one'))
    course_option2 = create(:course_option, course: create(:course, :open_on_apply, degree_grade: 'two_two'))
    course_option3 = create(:course_option, course: create(:course, :open_on_apply, degree_grade: 'third_class'))
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
    @choice3 = create(
      :application_choice,
      status: :unsubmitted,
      course_option: course_option3,
      application_form: current_candidate.current_application,
    )
  end

  def when_i_add_a_two_two_degree
    visit candidate_interface_degree_review_path

    click_link_or_button 'Add a degree'

    choose 'United Kingdom'
    click_link_or_button t('save_and_continue')

    choose 'Bachelor degree'
    click_link_or_button t('save_and_continue')

    select 'History', from: 'What subject is your degree?'
    click_link_or_button t('save_and_continue')

    choose 'Bachelor of Arts (BA)'
    click_link_or_button t('save_and_continue')

    select 'University of Warwick', from: 'candidate_interface_degree_wizard[university]'
    click_link_or_button t('save_and_continue')

    expect(page).to have_content('Have you completed your degree?')
    choose 'Yes'
    click_link_or_button t('save_and_continue')

    choose 'Lower second-class honours (2:2)'
    click_link_or_button t('save_and_continue')

    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2006'
    click_link_or_button t('save_and_continue')
    fill_in t('page_titles.what_year_did_you_graduate'), with: '2009'
    click_link_or_button t('save_and_continue')
    choose t('application_form.completed_radio')
    click_link_or_button t('continue')
  end

  def and_i_visit_the_course_choice_review_page
    visit candidate_interface_course_choices_review_path
  end

  def then_i_can_see_course_choices_with_relevant_guidance_for_one_course
    within "#course-choice-#{@choice1.id}" do
      expect(page).to have_content('Degree requirements')
      expect(page).to have_content('2:1 degree or higher (or equivalent)')
      expect(page).to have_content('You said you have a 2:2 degree.')
      expect(page).to have_content("You can:\nfind a course that has a lower degree requirement contact the provider to see if they will still consider your application")
    end

    within "#course-choice-#{@choice2.id}" do
      expect(page).to have_content('Degree requirements')
      expect(page).to have_content('2:2 degree or higher (or equivalent)')
      expect(page).to have_no_content('You said you have a 2:2 degree.')
      expect(page).to have_no_content("You can:\nfind a course that has a lower degree requirement contact the provider to see if they will still consider your application")
    end

    within "#course-choice-#{@choice3.id}" do
      expect(page).to have_content('Degree requirements')
      expect(page).to have_content('Third-class degree or higher (or equivalent)')
      expect(page).to have_no_content('You said you have a 2:2 degree.')
      expect(page).to have_no_content("You can:\nfind a course that has a lower degree requirement contact the provider to see if they will still consider your application")
    end
  end

  def when_i_change_my_degree_grade_to_a_pass
    visit candidate_interface_degree_review_path
    click_change_link('grade')
    choose 'Pass'
    click_link_or_button t('save_and_continue')
  end

  def then_i_can_view_course_choices_with_relevant_guidance_for_all_courses
    within "#course-choice-#{@choice1.id}" do
      expect(page).to have_content('Degree requirements')
      expect(page).to have_content('2:1 degree or higher (or equivalent)')
      expect(page).to have_content('You said you have an Ordinary degree (pass).')
      expect(page).to have_content("You can:\nfind a course that has a lower degree requirement contact the provider to see if they will still consider your application")
    end

    within "#course-choice-#{@choice2.id}" do
      expect(page).to have_content('Degree requirements')
      expect(page).to have_content('2:2 degree or higher (or equivalent)')
      expect(page).to have_content('You said you have an Ordinary degree (pass).')
      expect(page).to have_content("You can:\nfind a course that has a lower degree requirement contact the provider to see if they will still consider your application")
    end

    within "#course-choice-#{@choice3.id}" do
      expect(page).to have_content('Degree requirements')
      expect(page).to have_content('Third-class degree or higher (or equivalent)')
      expect(page).to have_content('You said you have an Ordinary degree (pass).')
      expect(page).to have_content("You can:\nfind a course that has a lower degree requirement contact the provider to see if they will still consider your application")
    end
  end
end

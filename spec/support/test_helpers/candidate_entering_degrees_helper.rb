module CandidateEnteringDegreesHelper
  def and_i_have_application_choices_in_draft
    @application_form = current_candidate.current_application
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    @course_1 = create(
      :course,
      :open,
      code: '238T',
      provider: @provider,
      level: 'secondary',
      degree_grade: 'two_one',
    )
    @course_2 = create(
      :course,
      :open,
      code: 'F35X',
      provider: @provider,
      level: 'secondary',
      degree_grade: 'two_one',
    )
    @course_option_1 = create(:course_option, course: @course_1)
    @course_option_2 = create(:course_option, course: @course_2)

    @application_choice_1 = create(
      :application_choice,
      :unsubmitted,
      course_option: @course_option_1,
      application_form: @application_form,
    )
    @application_choice_2 = create(
      :application_choice,
      :unsubmitted,
      course_option: @course_option_2,
      application_form: @application_form,
    )
    @application_choice_1.reload
    @application_choice_2.reload

    @application_form.application_choices << [@application_choice_1, @application_choice_2]
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end

  def then_i_can_see_the_country_page
    expect(page).to have_content('Which country was the degree from?')
  end

  def when_i_choose_united_kingdom
    choose 'United Kingdom'
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def when_i_fill_in_the_type
    choose 'Bachelor’s degree'
  end

  def then_i_can_see_the_level_page
    expect(page).to have_content 'What type of degree is it?'
  end

  def when_i_choose_the_level
    choose 'Bachelor'
  end

  def then_i_can_see_the_subject_page
    expect(page).to have_content 'What subject is your degree?'
  end

  def when_i_fill_in_the_subject
    select 'History', from: 'What subject is your degree?'
  end

  def then_i_can_see_the_type_page
    expect(page).to have_content 'What type of bachelor’s degree is it?'
  end

  def when_i_choose_the_type_of_degree
    choose 'Bachelor of Arts (BA)'
  end

  def then_i_can_see_the_university_page
    expect(page).to have_content 'Which university awarded your degree?'
  end

  def when_i_fill_in_the_university
    select 'University of Cambridge', from: 'Which university awarded your degree?'
  end

  def when_i_fill_in_the_university_with_free_text
    fill_in 'candidate_interface_degree_form[university_raw]', with: 'Test Uni  '
    # Triggering the autocomplete
    find('input[name="candidate_interface_degree_form[university_raw]"]').native.send_keys(:return)
  end

  def then_i_can_see_the_completion_page
    expect(page).to have_content 'Have you completed your degree?'
  end

  def when_i_choose_whether_degree_is_completed
    choose 'Yes'
  end

  def then_i_can_see_the_grade_page
    expect(page).to have_content('What grade is your degree?')
  end

  def when_i_select_the_grade
    choose 'First-class honours'
  end

  def when_i_select_the_grade_is_a_third_class
    choose 'Third-class honours'
  end

  def then_i_can_see_the_start_year_page
    expect(page).to have_content('What year did you start your degree?')
  end

  def when_i_fill_in_the_start_year
    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2006'
  end

  def then_i_can_see_the_award_year_page
    expect(page).to have_content('What year did you graduate?')
  end

  def when_i_fill_in_the_award_year
    fill_in t('page_titles.what_year_did_you_graduate'), with: '2009'
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degree_review_path
    expect(page).to have_content 'History'
  end

  def when_i_click_on_continue
    click_link_or_button t('continue')
  end
  alias and_i_click_on_continue when_i_click_on_continue

  def when_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def then_i_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def and_that_the_section_is_completed
    expect(page).to have_css('#degree-badge-id', text: 'Completed')
  end

  def then_i_can_check_my_answers
    expect(page).to have_content 'United Kingdom'
    expect(page).to have_content 'BA'
    expect(page).to have_content 'Bachelor of Arts'
    expect(page).to have_content 'University of Cambridge'
    expect(page).to have_content 'First-class honours'
    expect(page).to have_content '2006'
    expect(page).to have_content '2009'
  end

  def then_i_can_check_my_answers_with_free_text_university
    expect(page).to have_content 'United Kingdom'
    expect(page).to have_content 'BA'
    expect(page).to have_content 'Bachelor of Arts'
    expect(page).to have_content 'Test Uni'
    expect(page).to have_content 'First-class honours'
    expect(page).to have_content '2006'
    expect(page).to have_content '2009'
  end

  def and_the_completed_section_radios_are_not_selected
    %w[
      candidate-interface-section-complete-form-completed-true-field
      candidate-interface-section-complete-form-completed-field
    ].each do |radio_id|
      expect(page).to have_no_checked_field(radio_id)
    end
  end

  def then_i_see_the_grade_interruption_page_referring_to_one_or_more_draft_applications
    expect(page).to have_content 'Your degree grade does not match the eligibility criteria for one or more of the courses you have drafted applications for'
    expect(page).to have_content 'One or more of the courses you have drafted applications for requires a degree grade of 2:1 or higher (or equivalent).'
    expect(page).to have_content 'You have said that your degree is a third-class honours.'
  end

  def and_i_click_on_continue_to_save_this_degree
    click_link_or_button 'Continue to save this degree'
  end

  def when_i_click_the_grade_change_link_and_press_save_and_continue
    within('div.govuk-summary-list__row', text: 'Grade') do
      click_link_or_button 'Change'
    end

    click_on 'Save and continue'
  end
  alias and_i_click_the_grade_change_link_and_press_save_and_continue when_i_click_the_grade_change_link_and_press_save_and_continue

  def when_i_delete_one_of_my_choices
    @current_candidate.current_application.application_choices.last.destroy!
  end

  def then_i_see_the_grade_interruption_page_referring_to_one_draft_application
    expect(page).to have_content 'Your degree grade does not match the eligibility criteria for the course you have drafted an application for'
    expect(page).to have_content 'The course you have drafted an application for requires a degree grade of 2:1 or higher (or equivalent).'
    expect(page).to have_content 'You have said that your degree is a third-class honours.'
  end

  def when_i_update_the_degree_grade_to_predicted
    @current_candidate.current_application.degree_qualifications.last.update(predicted_grade: true)
  end

  def then_i_see_the_degrees_review_page_and_no_interruption
    expect(page).to have_content 'Check your degree'
  end
end

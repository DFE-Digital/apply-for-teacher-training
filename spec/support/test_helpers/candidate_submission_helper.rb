module CandidateSubmissionHelper
  def and_i_have_one_application_in_draft
    @application_form = create(:application_form, :completed, candidate: @current_candidate)
    @application_choice = create(:application_choice, :unsubmitted, application_form: @application_form)
  end

  def when_i_submit_one_of_my_draft_applications
    when_i_click_to_continue_my_application
    when_i_click_to_review_my_application
    when_i_click_to_submit_my_application
  end

  def when_i_continue_my_draft_application
    when_i_visit_my_applications
    when_i_click_to_continue_my_application
  end

  def when_i_visit_my_applications
    visit candidate_interface_continuous_applications_choices_path
  end

  def when_i_click_to_continue_my_application
    click_link_or_button 'Continue application', match: :first
  end

  def when_i_click_to_review_my_application
    click_link_or_button 'Review application'
  end

  def when_i_click_to_submit_my_application
    click_link_or_button 'Confirm and submit application'
  end

  def when_i_continue_without_editing
    click_link_or_button 'Continue without editing'
  end

  def then_i_should_be_on_the_review_and_submit_page
    expect(page).to have_current_path(
      candidate_interface_continuous_applications_course_review_and_submit_path(@application_choice.id),
    )
  end

  def then_i_should_see_that_the_course_is_full
    expect(page).to have_content('You cannot apply to this course as there are no places left on it')
    expect(page).to have_content('You need to either remove or change this course choice.')
  end
end

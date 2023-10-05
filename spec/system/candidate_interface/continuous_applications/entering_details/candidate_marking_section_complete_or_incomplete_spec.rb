require 'rails_helper'

RSpec.feature 'Marking section as complete or incomplete', :continuous_applications do
  include CandidateHelper

  scenario 'when marking section redirects the user' do
    given_i_have_a_completed_application_form
    when_i_sign_in
    and_i_mark_a_section_as_incomplete
    then_i_should_be_redirected_to_your_details_page
    when_i_mark_a_section_as_complete
    and_all_sections_are_complete
    then_i_should_be_redirected_to_your_applications_page
  end

  scenario 'when not all sections are complete' do
    given_i_have_a_completed_application_form
    when_i_sign_in
    and_i_mark_a_section_as_incomplete
    then_i_see_the_incomplete_text
  end

  scenario 'when all sections are complete' do
    given_i_have_a_completed_application_form
    when_i_sign_in
    and_all_details_have_been_completed
    then_i_do_not_see_the_incomplete_text
  end

  scenario 'completion info text' do
    given_i_have_a_completed_application_form
    when_i_sign_in
    then_i_dont_see_the_incomplete_applications_text

    when_i_visit_the_details_page
    then_i_see_the_complete_details_text

    when_i_mark_a_section_as_incomplete
    then_i_dont_see_the_complete_details_text

    when_i_visit_the_applications_page
    then_i_see_the_incomplete_applications_text

    when_i_click_on_your_details
    then_i_should_be_redirected_to_your_details_page

    when_i_add_the_maximum_number_of_choices
    then_i_dont_see_the_complete_details_text
  end

  def and_i_click_on_your_details
    click_link 'Your details'
  end

  def then_i_do_not_see_the_incomplete_text
    expect(page).not_to have_text 'Complete these sections so that you can start applying to courses. Your details will be shared with the training provider when you apply.'
  end

  def then_i_see_the_incomplete_text
    expect(page).to have_text('Complete these sections so that you can start applying to courses. Your details will be shared with the training provider when you apply.')
  end

  def given_i_have_a_completed_application_form
    @application_form = create(
      :application_form,
      :completed,
      candidate: current_candidate,
      submitted_at: nil,
    )
    create(:application_choice, :unsubmitted, application_form: @application_form)
  end

  def when_i_sign_in
    login_as(current_candidate)
    visit root_path
  end

  def and_i_mark_a_section_as_incomplete
    mark_section(section: 'Declare any safeguarding issues', complete: false)
  end
  alias_method :when_i_mark_a_section_as_incomplete, :and_i_mark_a_section_as_incomplete

  def then_i_should_be_redirected_to_your_details_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_details_path)
  end

  def when_i_mark_a_section_as_complete
    mark_section(section: 'Declare any safeguarding issues', complete: true)
  end

  alias_method :and_all_details_have_been_completed, :when_i_mark_a_section_as_complete

  def and_all_sections_are_complete
    completed_application_form = CandidateInterface::CompletedApplicationForm.new(application_form: @application_form)
    expect(completed_application_form).to be_valid
  end

  def then_i_should_be_redirected_to_your_applications_page
    expect(page).to have_current_path candidate_interface_continuous_applications_choices_path
  end

  def mark_section(section:, complete:)
    complete_choice = complete.present? ? 'Yes, I have completed this section' : 'No, I’ll come back to it later'
    click_link 'Your details'
    click_link section
    choose(complete_choice)
    click_button 'Continue'
  end

  def when_i_visit_the_applications_page
    visit candidate_interface_continuous_applications_choices_path
  end

  def then_i_see_the_incomplete_applications_text
    expect(page).to have_text('You will not be able to submit applications until you have completed your details.')
  end

  def when_i_click_on_your_details
    click_link 'your details'
  end

  def then_i_dont_see_the_incomplete_applications_text
    expect(page).not_to have_text('You will not be able to submit applications until you have completed your details.')
  end

  def when_i_visit_the_details_page
    visit candidate_interface_continuous_applications_details_path
  end

  def then_i_see_the_complete_details_text
    expect(page).to have_text('You can add your applications.')
    expect(page).to have_text('You have completed your details')
    expect(page).to have_text('You can now start applying to courses.')
  end

  def then_i_dont_see_the_complete_details_text
    expect(page).not_to have_text('You can add your applications.')
    expect(page).not_to have_text('You have completed your details')
    expect(page).not_to have_text('You can now start applying to courses.')
  end

  def when_i_add_the_maximum_number_of_choices
    (ApplicationForm::MAXIMUM_NUMBER_OF_COURSE_CHOICES - 1).times do
      create(:application_choice, :unsubmitted, application_form: @application_form)
    end
  end
end

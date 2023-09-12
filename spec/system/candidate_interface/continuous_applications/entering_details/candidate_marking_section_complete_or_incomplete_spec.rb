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

  def then_i_should_be_redirected_to_your_details_page
    expect(page).to have_current_path(candidate_interface_continuous_applications_details_path)
  end

  def when_i_mark_a_section_as_complete
    mark_section(section: 'Declare any safeguarding issues', complete: true)
  end

  def and_all_sections_are_complete
    completed_application_form = CandidateInterface::CompletedApplicationForm.new(application_form: @application_form)
    expect(completed_application_form).to be_valid
  end

  def then_i_should_be_redirected_to_your_applications_page
    expect(page).to have_current_path candidate_interface_continuous_applications_choices_path
  end

  def mark_section(section:, complete:)
    complete_choice = complete.present? ? 'Yes, I have completed this section' : 'No, I’ll come back to it later'
    click_on 'Your details'
    click_link section
    choose(complete_choice)
    click_on 'Continue'
  end
end

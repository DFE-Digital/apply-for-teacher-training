require 'rails_helper'

NonEditableSection = Struct.new(:identifier, :title)
RSpec.describe 'A candidate can not edit some sections after first submission' do
  include SignInHelper
  include CandidateHelper

  before do
    create_and_sign_in_candidate
  end

  [
    NonEditableSection.new(:english_gcse, 'English GCSE or equivalent'),
    NonEditableSection.new(:maths_gcse, 'Maths GCSE or equivalent'),
    NonEditableSection.new(:other_qualifications, 'A levels and other qualifications'),
    NonEditableSection.new(:degree, 'Degree'),
    NonEditableSection.new(:references, 'References to be requested if you accept an offer'),
    NonEditableSection.new(:safeguarding, 'Declare any safeguarding issues'),
  ].each do |section|
    scenario "candidate can not edit section '#{section.title}' after submission" do
      @section = section
      given_i_already_have_one_submitted_application
      and_i_visit_your_details_page
      when_i_click_on_the_section_in_your_details_page
      then_i_can_see_that_is_not_editable
      and_i_can_not_edit_the_section
      and_the_section_still_be_complete
    end
  end

  def given_i_already_have_one_submitted_application
    application_form = create(
      :application_form,
      :completed,
      :with_degree_and_gcses,
      :with_a_levels,
      full_work_history: true,
      volunteering_experiences_count: 1,
      candidate: current_candidate,
    )
    create(
      :application_qualification,
      application_form:,
      level: 'degree',
      qualification_type: 'Bachelor of Science',
      subject: 'Accountancy',
      grade: 'First-class honours',
      predicted_grade: false,
      award_year: '2020',
      institution_name: 'AA School of Architecture',
    )
    create(:application_choice, :awaiting_provider_decision, application_form:)
  end

  def and_i_visit_your_details_page
    visit candidate_interface_details_path
  end

  def when_i_click_on_the_section_in_your_details_page
    click_link_or_button @section.title
  end

  def then_i_can_see_that_is_not_editable
    expect(page).to have_no_content('Have you completed this section?')
    expect(page).to have_no_content('Yes, I have completed this section')
    expect(page).to have_no_content('Change')
    expect(page).to have_no_content('Any changes you make will be included in applications you have already submitted.')
    expect(page.all('button').map(&:text)).not_to include('Continue')
  end

  def and_i_can_not_edit_the_section
    method_name = "and_i_can_not_edit_the_section_#{@section.identifier}"

    if respond_to?(method_name)
      public_send(method_name)
    else
      raise "Method #{method_name} needs to be implemented in the spec"
    end
  end

  def and_the_section_still_be_complete
    click_link_or_button 'Your details'

    expect(
      section_status,
    ).to eq("#{@section.title} Completed")
  end

  def and_i_can_not_edit_the_section_unpaid_experience
    expect(page).to have_no_content('Add another role')

    visit candidate_interface_edit_volunteering_role_path(
      current_candidate.current_application.application_volunteering_experiences.last,
    )

    and_i_be_redirected_to_your_details_page
  end

  def and_i_can_not_edit_the_section_other_qualifications
    visit candidate_interface_edit_other_qualification_type_path(
      current_candidate.current_application.application_qualifications.a_levels.first,
    )

    and_i_be_redirected_to_your_details_page
  end

  def and_i_can_not_edit_the_section_degree
    expect(page).to have_no_content('Add another degree')
    visit candidate_interface_degree_country_path

    and_i_be_redirected_to_your_details_page
  end

  def and_i_can_not_edit_the_section_safeguarding
    visit candidate_interface_edit_safeguarding_path

    and_i_be_redirected_to_your_details_page
  end

  def and_i_can_not_edit_the_section_english_gcse
    visit candidate_interface_edit_gcse_english_grade_path

    and_i_be_redirected_to_your_details_page
  end

  def and_i_can_not_edit_the_section_maths_gcse
    visit candidate_interface_edit_gcse_maths_grade_path

    and_i_be_redirected_to_your_details_page
  end

  def and_i_can_not_edit_the_section_references
    expect(page).to have_no_content('Add another reference')

    visit candidate_interface_references_edit_name_path(
      current_candidate.current_application.application_references.last,
    )

    and_i_be_redirected_to_your_details_page
  end

  def and_i_can_not_edit_the_section_work_history
    visit candidate_interface_edit_restructured_work_history_path(
      current_candidate.current_application.application_work_experiences.last,
    )

    and_i_be_redirected_to_your_details_page
  end

  def when_i_save_and_continue
    click_link_or_button 'Save and continue'
  end

  def and_i_can_not_the_section_contact_information
    click_link_or_button 'Change phone number'
    fill_in 'Phone number', with: '707070707070'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.phone_number).to eq('707070707070')
  end

  def and_i_can_not_the_section_ask_for_support_if_you_are_disabled
    click_link_or_button 'Change whether you want to ask for help'
    choose 'Yes, I want to share information about myself so my provider can take steps to support me'
    fill_in 'Give any relevant information', with: 'Rerum qui maxime.'
    click_link_or_button 'Continue'

    expect(current_candidate.current_application.reload.disability_disclosure).to eq('Rerum qui maxime.')
  end

  def and_i_can_not_the_section_interview_availability
    click_link_or_button 'Change interview availability', match: :first
    choose 'Yes'
    fill_in 'Give details of times or dates that you are not available for interviews', with: 'Quis et enim.'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.interview_preferences).to eq('Quis et enim.')
  end

  def and_i_can_not_the_section_equality_and_diversity_information
    click_link_or_button 'Change sex'
    choose 'Male'
    click_link_or_button 'Continue'

    expect(current_candidate.current_application.reload.equality_and_diversity).to include('sex' => 'male')
  end

  def and_i_can_not_the_section_personal_statement
    click_link_or_button 'Edit your answer'
    fill_in 'Your personal statement', with: 'Repellat qui et'
    click_link_or_button 'Continue'

    expect(current_candidate.current_application.reload.becoming_a_teacher).to eq('Repellat qui et')
  end

  def and_i_be_redirected_to_your_details_page
    expect(page).to have_current_path candidate_interface_details_path
  end

  def section_status
    page.find(:xpath, "//a[contains(text(),'#{@section.title}')]/..").text
  end
end

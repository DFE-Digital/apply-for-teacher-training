require 'rails_helper'

TestSection = Struct.new(:identifier, :title)
RSpec.describe 'A candidate can edit some sections after first submission' do
  include SignInHelper
  include CandidateHelper

  before do
    create_and_sign_in_candidate
    values_checker = instance_double(EqualityAndDiversity::ValuesChecker)
    allow(EqualityAndDiversity::ValuesChecker).to receive(:new).and_return(values_checker)
    allow(values_checker).to receive(:check_values).and_return true
  end

  [
    TestSection.new(:personal_information, 'Personal information'),
    TestSection.new(:contact_information, 'Contact information'),
    TestSection.new(:ask_for_support_if_you_are_disabled, 'Ask for support if you are disabled'),
    TestSection.new(:interview_availability, 'Interview availability'),
    TestSection.new(:equality_and_diversity_information, 'Equality and diversity questions'),
    TestSection.new(:personal_statement, 'Your personal statement'),
    TestSection.new(:work_history, 'Work history'),
    TestSection.new(:unpaid_experience, 'Unpaid experience'),
  ].each do |section|
    scenario "candidate can edit section '#{section.title}' after submission" do
      @section = section
      given_i_already_have_one_submitted_application
      and_i_visit_your_details_page
      when_i_click_on_the_section_in_your_details_page
      then_i_can_see_that_is_editable
      and_i_can_edit_the_section
      and_the_section_still_be_complete
      when_i_click_on_the_section_in_your_details_page
      when_i_click_continue
      then_the_section_still_be_complete
    end
  end

  def given_i_already_have_one_submitted_application
    application_form = create(
      :application_form,
      :completed,
      candidate: current_candidate,
      volunteering_experiences_count: 1,
      full_work_history: true,
      work_history_status: :can_complete,
    )
    create(:application_choice, :awaiting_provider_decision, application_form:)
  end

  def and_i_visit_your_details_page
    visit candidate_interface_details_path
  end

  def when_i_click_on_the_section_in_your_details_page
    click_link_or_button @section.title
  end

  def then_i_can_see_that_is_editable
    expect(page.all('a').map(&:text)).to include('Continue')
  end

  def and_i_can_edit_the_section
    work_experiences = %i[unpaid_experience work_history]

    expected_content = if @section.identifier == :personal_statement
                         'Any changes you make to your personal statement will not be included in applications you have already submitted.'
                       elsif work_experiences.include?(@section.identifier)
                         'Any changes you make will not be included in applications you have already submitted.'
                       else
                         'Any changes you make will be included in applications you have already submitted.'
                       end

    expect(page).to have_content(expected_content)

    method_name = "and_i_can_edit_the_section_#{@section.identifier}"

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
  alias_method :then_the_section_still_be_complete, :and_the_section_still_be_complete

  def and_i_can_edit_the_section_personal_information
    click_link_or_button 'Change name'
    fill_in 'First name', with: 'Robert'
    fill_in 'Last name', with: 'Frank'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.full_name).to eq('Robert Frank')

    expect(page).to have_no_link('Change nationality')
  end

  def when_i_save_and_continue
    click_link_or_button 'Save and continue'
  end

  def when_i_click_continue
    click_link_or_button 'Continue'
  end

  def and_i_can_edit_the_section_contact_information
    click_link_or_button 'Change phone number'
    fill_in 'Phone number', with: '707070707070'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.phone_number).to eq('707070707070')
  end

  def and_i_can_edit_the_section_ask_for_support_if_you_are_disabled
    click_link_or_button 'Change whether you want to ask for help'
    choose 'Yes, I want to share information about myself so my provider can take steps to support me'
    fill_in 'Give any relevant information', with: 'Rerum qui maxime.'
    click_link_or_button 'Continue'

    expect(current_candidate.current_application.reload.disability_disclosure).to eq('Rerum qui maxime.')
  end

  def and_i_can_edit_the_section_interview_availability
    click_link_or_button 'Change interview availability', match: :first
    choose 'Yes'
    fill_in 'Give details of times or dates that you are not available for interviews', with: 'Quis et enim.'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.interview_preferences).to eq('Quis et enim.')
  end

  def and_i_can_edit_the_section_equality_and_diversity_information
    click_link_or_button 'Change sex'
    choose 'Male'
    click_link_or_button 'Continue'

    expect(current_candidate.current_application.reload.equality_and_diversity).to include('sex' => 'male')
  end

  def and_i_can_edit_the_section_personal_statement
    click_link_or_button 'Edit your personal statement'
    fill_in 'Your personal statement', with: 'Repellat qui et'
    click_link_or_button 'Continue'

    expect(current_candidate.current_application.reload.becoming_a_teacher).to eq('Repellat qui et')
  end

  def and_i_can_edit_the_section_work_history
    work_experience = current_candidate.current_application.application_work_experiences.first
    work_break = current_candidate.current_application.application_work_history_breaks.first
    click_link_or_button "Change job #{work_experience.role} for #{work_experience.organisation}"
    fill_in 'Name of employer', with: 'New employer'
    when_i_save_and_continue

    click_link_or_button(
      'Change entry for break between ' \
      "#{work_break.start_date.to_fs(:short_month_and_year)} and " \
      "#{work_break.end_date.to_fs(:short_month_and_year)}",
    )
    fill_in 'Enter reasons for break in work history', with: 'New reason'
    when_i_click_continue

    expect(work_experience.reload.organisation).to eq('New employer')
    expect(work_break.reload.reason).to eq('New reason')
  end

  def and_i_can_edit_the_section_unpaid_experience
    volunteering = current_candidate.current_application.application_volunteering_experiences.first
    click_link_or_button "Change role for #{volunteering.role}, #{volunteering.organisation}"
    fill_in 'Your role', with: 'New role'
    when_i_save_and_continue

    expect(volunteering.reload.role).to eq('New role')
  end

  def section_status
    page.find(:xpath, "//a[contains(text(),'#{@section.title}')]/..").text
  end
end

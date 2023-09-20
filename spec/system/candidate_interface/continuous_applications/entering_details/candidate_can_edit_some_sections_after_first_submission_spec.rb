require 'rails_helper'

TestSection = Struct.new(:identifier, :title)
RSpec.feature 'A candidate can edit some sections after first submission', :continuous_applications do
  include SignInHelper
  include CandidateHelper

  before do
    FeatureFlag.activate(:one_personal_statement)
    create_and_sign_in_candidate
  end

  [
    TestSection.new(:personal_information, 'Personal information'),
    TestSection.new(:contact_information, 'Contact information'),
    TestSection.new(:ask_for_support_if_you_are_disabled, 'Ask for support if you’re disabled'),
    TestSection.new(:interview_availability, 'Interview availability'),
    TestSection.new(:equality_and_diversity_information, 'Equality and diversity questions'),
    TestSection.new(:personal_statement, 'Your personal statement'),
  ].each do |section|
    scenario "candidate can edit section '#{section.title}' after submission" do
      given_i_already_have_one_submitted_application
      and_i_visit_your_details_page
      when_i_click_on_the_section_in_your_details_page(section:)
      then_i_can_see_that_is_editable
      and_i_can_edit_the_section(section:)
      and_the_section_should_still_be_complete(section:)
      and_i_can_mark_the_section_incomplete(section:)
      and_i_can_mark_the_section_complete(section:)
    end
  end

  def given_i_already_have_one_submitted_application
    application_form = create(:application_form, :completed, candidate: current_candidate)
    create(:application_choice, :awaiting_provider_decision, application_form:)
  end

  def and_i_visit_your_details_page
    visit candidate_interface_continuous_applications_details_path
  end

  def when_i_click_on_the_section_in_your_details_page(section:)
    click_on section.title
  end

  def then_i_can_see_that_is_editable
    expect(page).to have_content('Have you completed this section?')
    expect(page).to have_content('Yes, I have completed this section')
    expect(page.all('button').map(&:text)).to include('Continue')
  end

  def and_i_can_edit_the_section(section:)
    method_name = "and_i_can_edit_the_section_#{section.identifier}"

    if respond_to?(method_name)
      public_send(method_name)
    else
      raise "Method #{method_name} needs to be implemented in the spec"
    end
  end

  def and_the_section_should_still_be_complete(section:)
    click_on 'Your details'

    expect(
      section_status(section:),
    ).to eq("#{section.title} Completed")
  end

  def and_i_can_edit_the_section_personal_information
    click_on 'Change name'
    fill_in 'First name', with: 'Robert'
    fill_in 'Last name', with: 'Frank'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.full_name).to eq('Robert Frank')

    click_on 'Change nationality'
    check 'Irish'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.nationalities).to include('Irish')
  end

  def when_i_save_and_continue
    click_on 'Save and continue'
  end

  def and_i_can_edit_the_section_contact_information
    click_on 'Change phone number'
    fill_in 'Phone number', with: '707070707070'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.phone_number).to eq('707070707070')
  end

  def and_i_can_edit_the_section_ask_for_support_if_you_are_disabled
    click_on 'Change whether you want to ask for help'
    choose 'Yes, I want to share information about myself so my provider can take steps to support me'
    fill_in 'Give any relevant information', with: 'Rerum qui maxime.'
    click_on 'Continue'

    expect(current_candidate.current_application.reload.disability_disclosure).to eq('Rerum qui maxime.')
  end

  def and_i_can_edit_the_section_interview_availability
    click_on 'Change interview availability', match: :first
    choose 'Yes'
    fill_in 'Give details of your interview availability', with: 'Quis et enim.'
    when_i_save_and_continue

    expect(current_candidate.current_application.reload.interview_preferences).to eq('Quis et enim.')
  end

  def and_i_can_edit_the_section_equality_and_diversity_information
    click_on 'Change sex'
    choose 'Male'
    click_on 'Continue'

    expect(current_candidate.current_application.reload.equality_and_diversity).to include('sex' => 'male')
  end

  def and_i_can_edit_the_section_personal_statement
    click_on 'Edit your answer'
    fill_in 'Your personal statement', with: 'Repellat qui et'
    click_on 'Continue'

    expect(current_candidate.current_application.reload.becoming_a_teacher).to eq('Repellat qui et')
  end

  def and_i_can_mark_the_section_incomplete(section:)
    and_i_visit_your_details_page
    click_on section.title
    choose 'No, I’ll come back to it later'
    click_on 'Continue'

    expect(section_status(section:)).to eq("#{section.title} Incomplete")
  end

  def and_i_can_mark_the_section_complete(section:)
    and_i_visit_your_details_page
    click_on section.title
    choose 'Yes, I have completed this section'
    click_on 'Continue'

    and_i_visit_your_details_page
    expect(section_status(section:)).to eq("#{section.title} Completed")
  end

  def section_status(section:)
    page.find(:xpath, "//a[contains(text(),'#{section.title}')]/..").text
  end
end

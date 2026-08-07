require 'rails_helper'

RSpec.describe 'Change science GCSE' do
  include DfESignInHelpers

  scenario 'Change the science qualification from outside the UK (percentage grade) on an application form', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision

    when_i_visit_the_application_page
    and_i_click_to_change_the_science_international_qualification
    then_i_see_the_form_to_change_the_applications_science_international_qualification

    when_i_clear_the_form_inputs
    and_click_on_update_details
    then_i_see_validation_errors_for_each_input

    when_i_enter_invalid_inputs
    and_click_on_update_details
    then_i_see_validation_error_for_entering_invalid_inputs

    when_i_enter_valid_inputs
    and_click_on_update_details
    then_i_see_the_gcse_grades_have_been_updated
    and_the_science_international_qualification_has_been_updated
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_choice_awaiting_provider_decision
    @application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
    )
    @science_gcse = create(
      :gcse_qualification,
      subject: 'science',
      qualification_type: 'non_uk',
      application_form: @application_form,
      comparable_uk_qualification: 'GCSE (grades A*-C / 9-4)',
      enic_reason: 'obtained',
      enic_reference: 'sfdbsdfbd',
      institution_country: 'IN',
      grade: '71%',
      non_uk_qualification_type: 'CBSE Class 10 (AISSE)',
      selected_grade_schema_id: 'dce2ff0f-018e-436f-9439-79c65ae2ed26',
    )

    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def and_i_click_to_change_the_science_international_qualification
    within('.app-edit-qualification') do
      click_link_or_button 'Change'
    end
  end

  def then_i_see_the_form_to_change_the_applications_science_international_qualification
    expect(page).to have_element(:h1, text: 'Edit science GCSE or equivalent')
    expect(page).to have_element(:dt, text: 'Type of qualification')
    expect(page).to have_element(:dd, text: 'Qualification from outside the UK')
    expect(page).to have_element(:dt, text: 'Country or territory')
    expect(page).to have_element(:dd, text: 'India')
    expect(page).to have_element(:dt, text: 'Qualification')
    expect(page).to have_element(:dd, text: 'CBSE Class 10 (AISSE)')

    expect(page).to have_field('Enter the candidate’s grade', with: '71')

    expect(page).to have_element(:legend, text: 'Does the candidate have a statement of comparability from UK ENIC')
    expect(page).to have_field('Yes, I have a statement of comparability', type: :radio, checked: true)
    expect(page).to have_field("I'm waiting for it to arrive", type: :radio)
    expect(page).to have_field('I will apply for one in the future', type: :radio)
    expect(page).to have_field('I do not need a statement of comparability', type: :radio)

    expect(page).to have_field('UK ENIC reference number', with: @science_gcse.enic_reference)

    expect(page).to have_element(:legend, text: 'Select the comparable UK qualification')
    expect(page).to have_field('GCSE (grades A*-C / 9-4)', type: :radio, checked: true)
    expect(page).to have_field('Between GCSE and GCE AS level', type: :radio)
    expect(page).to have_field('GCE Advanced Subsidiary (AS) level', type: :radio)
    expect(page).to have_field('GCE Advanced (A) level', type: :radio)

    expect(page).to have_field('Award year', with: @science_gcse.award_year)
    expect(page).to have_field('Zendesk ticket URL')
  end

  def structured_grades
    finder = InternationalQualifications::StructuredGcseOptionFinder.new(
      @science_gcse.institution_country,
      @science_gcse.subject,
    )
    selected_equivalent_qualification = finder.equivalent_qualifications.find do |qualification|
      qualification.name == @science_gcse.non_uk_qualification_type
    end
    selected_grade_schema = selected_equivalent_qualification.grade_schemas.first

    if selected_grade_schema.present?
      selected_grade_schema.likely_above_level_four +
        selected_grade_schema.likely_below_level_four
    else
      []
    end
  end

  def when_i_clear_the_form_inputs
    fill_in 'Enter the candidate’s grade', with: nil
    fill_in 'Award year', with: nil
    fill_in 'Zendesk ticket URL', with: nil
  end

  def and_click_on_update_details
    click_on 'Update details'
  end

  def then_i_see_validation_errors_for_each_input
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter the candidate’s grade')
      expect(page).to have_element(:li, text: 'Enter the year the candidate gained their qualification')
      expect(page).to have_element(:li, text: 'You must provide an audit comment')
    end
  end

  def when_i_enter_invalid_inputs
    fill_in 'Enter the candidate’s grade', with: 9999
    fill_in 'Award year', with: 'Invalid'
    fill_in 'Zendesk ticket URL', with: 'Invalid'
  end

  def then_i_see_validation_error_for_entering_invalid_inputs
    expect(page).to have_element(:h2, text: 'There is a problem')
    within('.govuk-error-summary__body') do
      expect(page).to have_element(:li, text: 'Enter a whole number less than or equal to 100')
      expect(page).to have_element(:li, text: 'Enter a real award year')
      expect(page).to have_element(:li, text: 'Enter a valid Zendesk ticket URL')
    end
  end

  def when_i_enter_valid_inputs
    fill_in 'Enter the candidate’s grade', with: 99
    choose "I'm waiting for it to arrive"
    fill_in 'UK ENIC reference number', with: 9999999999
    choose 'Between GCSE and GCE AS level'
    fill_in 'Award year', with: 1987
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_the_gcse_grades_have_been_updated
    within('.govuk-notification-banner--success') do
      expect(page).to have_text('GCSE updated')
    end
  end

  def and_the_science_international_qualification_has_been_updated
    expect(page).to have_element(:h4, text: 'Science CBSE Class 10 (AISSE)')
    expect(page).to have_element(:dt, text: 'Awarded')
    expect(page).to have_element(:dd, text: '1987, India')
    expect(page).to have_element(:dt, text: 'Grade')
    expect(page).to have_element(:dd, text: '99%')
  end
end

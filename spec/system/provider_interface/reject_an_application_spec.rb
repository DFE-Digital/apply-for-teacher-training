require 'rails_helper'

RSpec.describe 'Reject an application' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  scenario 'giving rejection reasons using rejection form', with_audited: true do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_my_organisation_has_received_an_application
    and_i_sign_in_to_the_provider_interface

    when_i_choose_to_reject_an_application

    then_i_can_navigate_back_to_the_make_decision_form
    and_i_give_reasons_why_i_am_rejecting_the_application
    and_i_click_continue
    and_i_check_the_reasons_for_rejection
    and_i_click_back
    then_i_can_see_the_rejection_reasons_form

    when_i_click_continue
    and_i_reject_the_application
    then_i_can_see_the_rejected_application_feedback
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    permit_make_decisions!
  end

  def and_my_organisation_has_received_an_application
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_choice = create(:application_choice, :with_completed_application_form, :awaiting_provider_decision, course_option:)
  end

  def when_i_choose_to_reject_an_application
    visit provider_interface_application_choice_path(@application_choice)

    click_on 'Make decision'
    choose 'Reject application'
    click_on t('continue')
  end

  def then_i_can_navigate_back_to_the_make_decision_form
    expect(page).to have_link('Back', href: new_provider_interface_application_choice_decision_path(@application_choice))
    click_on 'Back'

    choose 'Reject application'
    click_on t('continue')
  end

  def and_i_give_reasons_why_i_am_rejecting_the_application
    check 'rejection-reasons-selected-reasons-qualifications-field'
    check 'rejection-reasons-qualifications-selected-reasons-no-maths-gcse-field'
    check 'rejection-reasons-qualifications-selected-reasons-unverified-qualifications-field'
    fill_in 'rejection-reasons-unverified-qualifications-details-field', with: 'We can find no evidence of your GCSEs'

    check 'rejection-reasons-selected-reasons-personal-statement-field'
    check 'rejection-reasons-personal-statement-selected-reasons-quality-of-writing-field'
    fill_in 'rejection-reasons-quality-of-writing-details-field', with: 'We do not accept applications written in morse code'
    check 'rejection-reasons-personal-statement-selected-reasons-personal-statement-other-field'
    fill_in 'rejection-reasons-personal-statement-other-details-field', with: 'This was wayyyyy too personal'

    check 'rejection-reasons-selected-reasons-course-full-field'
    fill_in 'rejection-reasons-course-full-details-field', with: 'Other courses exist'
  end

  def and_i_check_the_reasons_for_rejection
    expect(page).to have_content('Check details and reject application')
    expect(page).to have_content('The candidate will be sent this email:')

    email = page.all('.app-email-preview').first.text.split("\n")

    expect(email[0..3]).to eq([
      "Dear #{@application_choice.application_form.first_name},",
      "Thank you for your application to study #{@application_choice.current_course_option.course.name_and_code} at #{@application_choice.current_course_option.provider.name}.",
      'On this occasion, the provider is not offering you a place on this course.',
      'They’ve given the following feedback to explain their decision:',
    ])

    expect(email[4..7]).to eq([
      'Qualifications',
      'No maths GCSE at minimum grade 4 or C, or equivalent',
      'Could not verify qualifications:',
      'We can find no evidence of your GCSEs',
    ])

    expect(email[8..12]).to eq([
      'Personal statement',
      'Quality of writing:',
      'We do not accept applications written in morse code',
      'Other:',
      'This was wayyyyy too personal',
    ])

    expect(email[13..15]).to eq([
      'Course full',
      'Course full:',
      'Other courses exist',
    ])

    expect(page).to have_button('Reject application')
  end

  def and_i_click_continue
    click_on 'Continue'
  end

  alias_method :when_i_click_continue, :and_i_click_continue

  def and_i_click_back
    click_on 'Back'
  end

  def then_i_can_see_the_rejection_reasons_form
    expect(page).to have_current_path(new_provider_interface_rejection_path(@application_choice))
  end

  def and_i_reject_the_application
    click_on 'Reject application'
  end

  def then_i_can_see_the_rejected_application_feedback
    expect(page).to have_content('Application rejected')

    expect(page).to have_content('Qualifications')
    expect(page).to have_content('No maths GCSE at minimum grade 4 or C, or equivalent')
    expect(page).to have_content('Could not verify qualifications:')
    expect(page).to have_content('We can find no evidence of your GCSEs')

    expect(page).to have_content('Personal statement')
    expect(page).to have_content('Quality of writing:')
    expect(page).to have_content('We do not accept applications written in morse code')
    expect(page).to have_content('Other:')
    expect(page).to have_content('This was wayyyyy too personal')

    expect(page).to have_content('Course full')
    expect(page).to have_content('Other courses exist')
  end
end

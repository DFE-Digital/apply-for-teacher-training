require 'rails_helper'

RSpec.describe 'Reject an application' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  scenario 'giving rejection reasons to a postgraduate application', :with_audited do
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

  scenario 'giving rejection reasons to an undergraduate application', :with_audited do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_my_organisation_has_received_an_undergraduate_application
    and_i_sign_in_to_the_provider_interface

    when_i_choose_to_reject_an_application

    then_i_can_navigate_back_to_the_make_decision_form
    and_i_give_a_level_reasons_why_i_am_rejecting_the_application
    and_i_click_continue
    and_i_check_the_a_level_reasons_for_rejection
    and_i_click_back
    then_i_can_see_the_rejection_reasons_form

    when_i_click_continue
    and_i_reject_the_application
    then_i_can_see_the_rejected_undergraduate_application_feedback
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

  def and_my_organisation_has_received_an_undergraduate_application
    provider = Provider.find_by(code: 'ABC') || create(:provider, code: 'ABC')
    course = create(:course, :teacher_degree_apprenticeship, provider:)
    course_option = create(:course_option, course:)
    @application_choice = create(
      :application_choice,
      :with_completed_application_form,
      :awaiting_provider_decision,
      course_option:,
    )
  end

  def when_i_choose_to_reject_an_application
    visit provider_interface_application_choice_path(@application_choice)

    click_link_or_button 'Make decision'
    choose 'Reject application'
    click_link_or_button t('continue')
  end

  def then_i_can_navigate_back_to_the_make_decision_form
    expect(page).to have_link('Back', href: new_provider_interface_application_choice_decision_path(@application_choice))
    click_link_or_button 'Back'

    choose 'Reject application'
    click_link_or_button t('continue')
  end

  def and_i_give_reasons_why_i_am_rejecting_the_application
    check 'Qualifications'
    and_the_a_levels_rejection_reason_is_not_visible_for_postgraduate_application

    within_fieldset 'Reasons for rejecting due to qualifications' do
      check 'No maths GCSE at minimum grade 4 or C, or equivalent'

      check 'Degree grade does not meet course requirements'
      fill_in 'Details about why their qualifications does not meet course requirements', with: 'Your grade does not match the course requirement'

      check 'Degree subject does not meet course requirements'
      fill_in 'Details about why their subject does not meet course requirements', with: 'Your subject does not match the course requirement'

      check 'Could not verify qualifications'
      fill_in 'Details about why you could not verify qualifications', with: 'We can find no evidence of your GCSEs'

      check 'Could not verify equivalency of qualifications'
      fill_in 'Details about why you could not verify equivalency qualifications', with: 'We can find no evidence of your GCSEs'
    end

    check 'Personal statement'

    within_fieldset 'Reasons for rejecting due to personal statement' do
      check 'Quality of writing'
      fill_in 'Details about their quality of writing', with: 'We do not accept applications written in morse code'
      check 'Other'
      fill_in 'Details of other issues with their personal statement', with: 'This was wayyyyy too personal'
    end

    check 'Communication, interview attendance and scheduling'

    within_fieldset 'Reasons for rejecting due to communication, interview attendance or scheduling' do
      check 'English language ability below expected standard'
      fill_in 'Details about the english ability being below expected standard', with: 'Your english level is below expected standard'
    end

    check 'Course full'
    check 'The salaried or apprenticeship route for this course is full'
    fill_in 'provider-interface-rejections-wizard-salary-course-full-details-field', with: 'Other courses exist'

    check 'provider-interface-rejections-wizard-selected-reasons-other-field'
    fill_in 'Details of other reasons', with: 'There are so many other reasons why your application was rejected...'

    check 'School placement'

    within_fieldset 'Reasons for rejecting due to school placement' do
      check 'No available placements'
      fill_in 'Details of why there are no placements', with: 'We are full'

      check 'No placements that are suitable'
      fill_in 'Details of why there are no suitable placements', with: 'Funding issues'

      check 'Other'
      fill_in 'Details of other rejection reasons regarding placements', with: 'Other issues'
    end
  end

  def and_i_give_a_level_reasons_why_i_am_rejecting_the_application
    check 'Qualifications'
    check 'A levels do not meet course requirements (Teacher Degree Apprenticeship courses only)'
    fill_in 'Details about why their A levels do not meet course requirements', with: 'A level below expected grade'
  end

  def and_i_check_the_a_level_reasons_for_rejection
    expect(page).to have_content('Check details and reject application')
    expect(email_preview[4..6]).to eq(
      [
        'Qualifications',
        'A levels do not meet course requirements:',
        'A level below expected grade',
      ],
    )
  end

  def and_i_check_the_reasons_for_rejection
    expect(page).to have_content('Check details and reject application')
    expect(page).to have_content('The candidate will be sent this email:')

    expect(email_preview[0..3]).to eq([
      "Dear #{@application_choice.application_form.first_name},",
      "Thank you for your application to study #{@application_choice.current_course_option.course.name_and_code} at #{@application_choice.current_course_option.provider.name}.",
      'On this occasion, the provider is not offering you a place on this course.',
      'They’ve given the following feedback to explain their decision:',
    ])

    expect(email_preview[4..13]).to eq([
      'Qualifications',
      'No maths GCSE at minimum grade 4 or C, or equivalent',
      'Degree grade does not meet course requirements:',
      'Your grade does not match the course requirement',
      'Degree subject does not meet course requirements:',
      'Your subject does not match the course requirement',
      'Could not verify qualifications:',
      'We can find no evidence of your GCSEs',
      'Could not verify equivalency of qualifications:',
      'We can find no evidence of your GCSEs',
    ])

    expect(email_preview[14..18]).to eq([
      'Personal statement',
      'Quality of writing:',
      'We do not accept applications written in morse code',
      'Other:',
      'This was wayyyyy too personal',
    ])

    expect(email_preview[19..21]).to eq([
      'Communication, interview attendance and scheduling',
      'English language ability below expected standard:',
      'Your english level is below expected standard',
    ])

    expect(email_preview[22..24]).to eq([
      'Course full',
      'The salaried or apprenticeship route for this course is full:',
      'Other courses exist',
    ])

    expect(email_preview[25..31]).to eq([
      'School placement',
      'No available placements:',
      'We are full',
      'No placements that are suitable:',
      'Funding issues',
      'Other:',
      'Other issues',
    ])

    expect(email_preview[32..34]).to eq([
      'Other',
      'Other:',
      'There are so many other reasons why your application was rejected...',
    ])

    expect(email_preview.last).to eq(
      "Contact #{@application_choice.current_course_option.provider.name} if you would like to talk about their feedback.",
    )

    expect(page).to have_button('Reject application')
  end

  def and_i_click_continue
    click_link_or_button 'Continue'
  end

  alias_method :when_i_click_continue, :and_i_click_continue

  def and_i_click_back
    click_link_or_button 'Back'
  end

  def then_i_can_see_the_rejection_reasons_form
    expect(page).to have_current_path(new_provider_interface_rejection_path(@application_choice))
  end

  def and_i_reject_the_application
    click_link_or_button 'Reject application'
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

    expect(page).to have_content('Other')
    expect(page).to have_content('There are so many other reasons why your application was rejected...')
  end

  def then_i_can_see_the_rejected_undergraduate_application_feedback
    expect(page).to have_content(
      'The following feedback was sent to the candidate. Qualifications A levels do not meet course requirements: A level below expected grade',
    )
  end

  def and_the_a_levels_rejection_reason_is_not_visible_for_postgraduate_application
    expect(page).to have_no_content('A levels do not meet course requirements')
  end

private

  def email_preview
    page.first('.app-email-preview').text.split("\n")
  end
end

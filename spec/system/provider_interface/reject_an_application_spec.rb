require 'rails_helper'

RSpec.describe 'Reject an application' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include CourseOptionHelpers

  scenario 'giving reasons for rejection', with_audited: true do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_my_organisation_has_received_an_application
    and_i_sign_in_to_the_provider_interface

    when_i_respond_to_an_application
    and_i_choose_to_reject_it

    then_i_give_reasons_why_i_am_rejecting_the_application
    and_i_check_the_reasons_for_rejection
    and_i_choose_to_change_some_reasons_for_rejection
    and_i_go_back_to_explain_the_reason_with_a_radio_button
    and_i_answer_additional_reasons
    and_i_check_the_amended_reasons_for_rejection
    and_i_choose_to_revert_my_changes
    and_i_recheck_my_reasons
    and_i_submit_the_reasons_for_rejection
    then_i_can_see_the_reasons_why_the_application_was_rejected

    and_when_i_click_back_link_in_the_browser
    then_i_can_see_that_the_application_has_already_been_rejected

    and_there_is_a_timeline_entry
    and_there_is_an_activity_log_entry
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
    @application_choice = create(:application_choice, :awaiting_provider_decision, course_option: course_option)
  end

  def when_i_respond_to_an_application
    visit provider_interface_application_choice_path(@application_choice)
    click_on 'Make decision'
  end

  def and_i_choose_to_reject_it
    choose 'Reject application'
    click_on t('continue')
  end

  def then_i_give_reasons_why_i_am_rejecting_the_application
    expect(page).to have_link('Back', href: new_provider_interface_application_choice_decision_path(@application_choice))

    choose 'reasons-for-rejection-candidate-behaviour-y-n-no-field'

    choose 'reasons-for-rejection-quality-of-application-y-n-no-field'

    choose 'reasons-for-rejection-qualifications-y-n-yes-field'
    check 'reasons-for-rejection-qualifications-which-qualifications-no-maths-gcse-field'
    check 'reasons-for-rejection-qualifications-which-qualifications-no-degree-field'

    choose 'reasons-for-rejection-performance-at-interview-y-n-no-field'

    choose 'reasons-for-rejection-course-full-y-n-no-field'

    choose 'reasons-for-rejection-offered-on-another-course-y-n-no-field'

    choose 'reasons-for-rejection-honesty-and-professionalism-y-n-yes-field'
    check 'reasons-for-rejection-honesty-and-professionalism-concerns-information-false-or-inaccurate-field'
    fill_in 'reasons-for-rejection-honesty-and-professionalism-concerns-information-false-or-inaccurate-details-field', with: 'We doubt claims about your golf handicap'
    check 'reasons-for-rejection-honesty-and-professionalism-concerns-references-field'
    fill_in 'reasons-for-rejection-honesty-and-professionalism-concerns-references-details-field', with: 'We cannot accept references from your mum'

    choose 'reasons-for-rejection-safeguarding-y-n-yes-field'
    check 'reasons-for-rejection-safeguarding-concerns-vetting-disclosed-information-field'
    fill_in 'reasons-for-rejection-safeguarding-concerns-vetting-disclosed-information-details-field', with: 'You abducted Jenny, now Matrix is coming to find her'

    choose 'reasons-for-rejection-cannot-sponsor-visa-y-n-no-field'

    click_on t('continue')
  end

  def and_i_check_the_reasons_for_rejection
    expect(page).to have_link('Back', href: provider_interface_reasons_for_rejection_initial_questions_path(@application_choice))

    expect(page).not_to have_content('Something you did')

    expect(page).not_to have_content('Quality of application')

    expect(page).to have_content('Qualifications')
    expect(page).to have_content('No Maths GCSE grade 4 (C) or above, or valid equivalent')
    expect(page).to have_content('No degree')

    expect(page).not_to have_content('Performance at interview')

    expect(page).to have_content('Honesty and professionalism')
    expect(page).to have_content('We doubt claims about your golf handicap')
    expect(page).to have_content('We cannot accept references from your mum')

    expect(page).to have_content('Safeguarding issues')
    expect(page).to have_content('You abducted Jenny, now Matrix is coming to find her')
  end

  def and_i_choose_to_change_some_reasons_for_rejection
    click_on 'Change', match: :first

    expect(page).to have_checked_field 'reasons-for-rejection-qualifications-y-n-yes-field'
    expect(page).to have_checked_field 'reasons-for-rejection-safeguarding-y-n-yes-field'
    expect(page).to have_checked_field 'reasons-for-rejection-honesty-and-professionalism-y-n-yes-field'

    choose 'reasons-for-rejection-qualifications-y-n-no-field'
    choose 'reasons-for-rejection-honesty-and-professionalism-y-n-no-field'
    choose 'reasons-for-rejection-safeguarding-y-n-no-field'

    click_on t('continue')
  end

  def and_i_go_back_to_explain_the_reason_with_a_radio_button
    expect(page).to have_selector('h1', text: 'Other reasons for rejecting this application')
    click_on 'Back'

    choose 'reasons-for-rejection-candidate-behaviour-y-n-yes-field'
    check 'reasons-for-rejection-candidate-behaviour-what-did-the-candidate-do-other-field'
    fill_in 'reasons-for-rejection-candidate-behaviour-other-field', with: "There was no need to sing 'Run to the Hills' for us"
    fill_in 'reasons-for-rejection-candidate-behaviour-what-to-improve-field', with: 'Leave the singing out next time'

    choose 'reasons-for-rejection-quality-of-application-y-n-yes-field'
    check 'reasons-for-rejection-quality-of-application-which-parts-needed-improvement-personal-statement-field'
    fill_in 'reasons-for-rejection-quality-of-application-personal-statement-what-to-improve-field', with: 'Telling people you are a stable genius might be a bit loaded'

    choose 'reasons-for-rejection-qualifications-y-n-yes-field'
    check 'reasons-for-rejection-qualifications-which-qualifications-no-maths-gcse-field'
    check 'reasons-for-rejection-qualifications-which-qualifications-no-degree-field'

    choose 'reasons-for-rejection-performance-at-interview-y-n-yes-field'
    fill_in 'reasons-for-rejection-performance-at-interview-what-to-improve-field', with: "Don't sing 'Run to the Hills' at the start of the interview"

    click_on t('continue')
  end

  def and_i_answer_additional_reasons
    expect(page).to have_link('Back', href: provider_interface_reasons_for_rejection_initial_questions_path(@application_choice))
    expect(page).to have_selector('h1', text: 'Is there any other advice or feedback you’d like to give')

    choose 'reasons-for-rejection-other-advice-or-feedback-y-n-yes-field'
    fill_in 'reasons-for-rejection-other-advice-or-feedback-details-field', with: 'While impressive, your parkour skills are not relevant'

    click_on t('continue')
  end

  def and_i_check_the_amended_reasons_for_rejection
    expect(page).to have_link('Back', href: provider_interface_reasons_for_rejection_other_reasons_path(@application_choice))

    expect(page).not_to have_content('Honesty and professionalism')
    expect(page).not_to have_content('Safeguarding issues')

    expect(page).to have_content('Additional feedback')
    expect(page).to have_content('While impressive, your parkour skills are not relevant')

    expect(page).not_to have_content('Future applications')
  end

  def and_i_choose_to_revert_my_changes
    click_on 'Change', match: :first

    expect(page).to have_checked_field 'reasons-for-rejection-safeguarding-y-n-no-field'
    expect(page).to have_checked_field 'reasons-for-rejection-honesty-and-professionalism-y-n-no-field'

    choose 'reasons-for-rejection-honesty-and-professionalism-y-n-yes-field'

    expect(page).to have_field('reasons-for-rejection-honesty-and-professionalism-concerns-information-false-or-inaccurate-details-field', with: '')
    expect(page).to have_field('reasons-for-rejection-honesty-and-professionalism-concerns-plagiarism-details-field', with: '')
    expect(page).to have_field('reasons-for-rejection-honesty-and-professionalism-concerns-references-details-field', with: '')

    check 'reasons-for-rejection-honesty-and-professionalism-concerns-references-field'
    fill_in 'reasons-for-rejection-honesty-and-professionalism-concerns-references-details-field', with: 'We cannot accept references from your gran'

    click_on t('continue')
  end

  def and_i_recheck_my_reasons
    expect(page).to have_current_path(provider_interface_reasons_for_rejection_check_path(@application_choice))

    expect(page).to have_content('Honesty and professionalism')
    expect(page).not_to have_content('Safeguarding issues')
  end

  def and_i_submit_the_reasons_for_rejection
    click_on 'Send feedback and reject application'
  end

  def then_i_can_see_the_reasons_why_the_application_was_rejected
    expect(page).to have_content('Application rejected')

    expect(page).to have_content('Feedback')

    expect(page).to have_content('The following feedback was sent to the candidate.')
    expect(page).to have_content('Something you did')
    expect(page).to have_content("There was no need to sing 'Run to the Hills' for us")
    expect(page).to have_content('Leave the singing out next time')
    expect(page).to have_content('Quality of application')
    expect(page).to have_content('Telling people you are a stable genius might be a bit loaded')
    expect(page).to have_content('Qualifications')
    expect(page).to have_content("No Maths GCSE grade 4 (C) or above, or valid equivalent.\nNo degree.")
    expect(page).to have_content('Performance at interview')
    expect(page).to have_content("Don't sing 'Run to the Hills' at the start of the interview")
    expect(page).to have_content('Honesty and professionalism')
    expect(page).to have_content('We cannot accept references from your gran')
  end

  def and_when_i_click_back_link_in_the_browser
    visit provider_interface_reasons_for_rejection_check_path(@application_choice)
  end

  def then_i_can_see_that_the_application_has_already_been_rejected
    expect(page).to have_current_path(provider_interface_application_choice_feedback_path(@application_choice))
    expect(page).to have_content('This application has already been rejected.')
  end

  def and_there_is_a_timeline_entry
    click_on 'Timeline'

    expect(page).to have_content('Application rejected')
    expect(page).to have_link('View application', href: provider_interface_application_choice_path(@application_choice))
  end

  def and_there_is_an_activity_log_entry
    FeatureFlag.activate(:provider_activity_log)
    page.refresh # remove with the above feature flag

    click_on 'Activity log'

    expect(page).to have_content('rejected')
    expect(page).to have_link('View application', href: provider_interface_application_choice_path(@application_choice))
  end
end

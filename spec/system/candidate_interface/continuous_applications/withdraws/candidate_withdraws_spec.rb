require 'rails_helper'

RSpec.feature 'A candidate withdraws their application', :bullet do
  include CandidateHelper

  # bullet complains about wanting an includes on associated objects.
  # You cannot call includes on a build_stubbed object.
  # Our mailer previews are reliant on build_stubbed so we need to exclude this test.

  before do
    Bullet.raise = false
  end

  after do
    Bullet.raise = true
  end

  scenario 'successful withdrawal' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_multiple_application_choice_awaiting_provider_decision

    when_i_visit_the_application_dashboard
    and_i_click_the_withdraw_link_on_my_first_choice
    then_i_see_a_confirmation_page
    and_i_do_not_see_the_interview_related_text

    when_i_click_to_confirm_withdrawal
    then_i_see_the_withdraw_choice_reason_page
    and_the_provider_has_received_an_email

    when_i_select_my_reasons
    and_i_click_continue
    then_i_see_my_application_dashboard
    and_i_am_thanked_for_my_feedback

    when_i_try_to_visit_the_withdraw_page
    then_i_see_the_page_not_found

    when_i_visit_the_application_dashboard
    and_i_click_the_withdraw_link_on_my_final_choice
    then_i_see_a_confirmation_page

    when_i_click_to_confirm_withdrawal
    when_i_select_my_reasons
    and_i_click_continue
    and_the_candidate_has_received_an_email_with_information_on_apply_again
  end

  scenario 'withdrawal for application choice with interviewing status' do
    given_i_am_signed_in_as_a_candidate
    and_i_have_an_application_choice_with_the_status_interviewing

    when_i_visit_the_application_dashboard
    and_i_click_the_withdraw_link_on_my_application_choice_with_the_status_interviewing
    then_i_see_a_confirmation_page
    and_i_also_see_the_interview_related_text
  end

  def given_i_am_signed_in_as_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_have_multiple_application_choice_awaiting_provider_decision
    form = create(:completed_application_form, :with_completed_references, candidate: current_candidate)
    @application_choice = create(:application_choice, :awaiting_provider_decision, application_form: form)
    @second_application_choice = create(:application_choice, :awaiting_provider_decision, application_form: form)
    @provider_user = create(:provider_user, :with_notifications_enabled)
    create(:provider_permissions, provider_id: @application_choice.provider.id, provider_user_id: @provider_user.id)
  end

  def and_i_have_an_application_choice_with_the_status_interviewing
    form = create(:completed_application_form, :with_completed_references, candidate: current_candidate)
    @interviewing_application_choice = create(:application_choice, :interviewing, application_form: form)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_continuous_applications_choices_path
  end

  def and_i_click_the_withdraw_link_on_my_first_choice
    click_withdraw_link @application_choice
  end

  def and_i_click_the_withdraw_link_on_my_final_choice
    click_withdraw_link @second_application_choice
  end

  def and_i_click_the_withdraw_link_on_my_application_choice_with_the_status_interviewing
    click_withdraw_link @interviewing_application_choice
  end

  def then_i_see_a_confirmation_page
    expect(page).to have_content("Once you have a total of #{ApplicationForm::MAXIMUM_NUMBER_OF_UNSUCCESSFUL_APPLICATIONS} unsuccessful or withdrawn applications, you will not be able to apply for any more courses until October #{RecruitmentCycle.real_current_year}")
    expect(page).to have_content('Do not withdraw if you need to change information on your application. Tell your training provider instead.')
  end

  def and_i_also_see_the_interview_related_text
    expect(page).to have_content('If you do withdraw, your scheduled interview for this application will be cancelled.')
  end

  def and_i_do_not_see_the_interview_related_text
    expect(page).to have_no_content('If you do withdraw, your scheduled interview for this application will be cancelled.')
  end

  def when_i_click_to_confirm_withdrawal
    click_link_or_button 'Yes I’m sure – withdraw this application'
  end

  def then_i_see_the_withdraw_choice_reason_page
    expect(page).to have_current_path candidate_interface_withdrawal_feedback_path(@application_choice.id)
  end

  def when_i_try_to_visit_the_withdraw_page
    visit candidate_interface_withdraw_path(id: @application_choice.id)
  end

  def then_i_see_the_page_not_found
    expect(page).to have_content('Page not found')
  end

  def and_the_provider_has_received_an_email
    open_email(@provider_user.email_address)
    expect(current_email.subject).to have_content "#{@application_choice.application_form.full_name} withdrew their application"
  end

  def when_i_submit_the_questionnaire_without_choosing_options
    click_link_or_button t('continue')
  end

  def then_i_am_asked_to_choose_my_reasons
    expect(page).to have_content 'Select at least one reason'
  end

  def when_i_select_my_reasons
    check 'I’m going to apply (or have applied) to a different course at the same training provider', match: :first
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def then_i_see_my_application_dashboard
    expect(page).to have_current_path candidate_interface_continuous_applications_choices_path
  end

  def and_i_am_thanked_for_my_feedback
    expect(page).to have_content("Your application for #{@application_choice.course_option.course.name_and_code} at #{@application_choice.course_option.provider.name} has been withdrawn")
  end

  def and_the_candidate_has_received_an_email_with_information_on_apply_again
    open_email(@application_choice.application_form.candidate.email_address)
    expect(current_email.subject).to have_content 'You’ve withdrawn your application'
  end

  def click_withdraw_link(application_choice)
    within "#course-choice-#{application_choice.id}" do
      click_link_or_button 'Withdraw'
    end
  end
end

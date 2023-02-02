require 'rails_helper'

RSpec.feature 'Provider adds SKE conditions', feature_flag: :provider_ske do
  include DfESignInHelpers

  scenario 'Non-language subjects' do
    when_a_provider_adds_ske_conditions_to_a_non_language_offer
    then_the_provider_should_be_taken_to_the_offer_summary_page
    and_the_conditions_should_be_displayed

    when_the_provider_changes_the_length_of_the_ske_course
    then_the_provider_should_be_taken_to_the_offer_summary_page
    and_the_conditions_should_be_displayed

    when_the_provider_changes_the_reason_for_the_ske_course
    then_the_provider_should_be_taken_to_the_offer_summary_page
    and_the_conditions_should_be_displayed
  end

private

  def when_a_provider_adds_ske_conditions_to_a_non_language_offer
    @application_choice = Satisfactory.root
      .add(:application_choice)
      .which_is(:with_completed_application_form, :awaiting_provider_decision)
      .with(:course_option).which_is(:open_on_apply)
      .with(:course).with(:subject).which_is(:non_language)
      .create[:application_choice].first

    @subject = @application_choice.course.subjects.first
    candidate_name = @application_choice.application_form.full_name

    @provider = @application_choice.provider
    provider_user = @provider.provider_users.first
    provider_user.provider_permissions.update_all(make_decisions: true)

    user_exists_in_dfe_sign_in(
      email_address: provider_user.email_address,
      dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
    )
    provider_signs_in_using_dfe_sign_in

    visit provider_interface_applications_path

    click_on candidate_name
    click_on 'Make decision'
    choose 'Make an offer'
    click_on 'Continue'

    choose 'Yes'
    click_on 'Continue'

    choose "Their degree subject was not #{@subject.name}"
    click_on 'Continue'

    expect(page).to have_content('How long must their SKE course be?')
    choose '16 weeks'
    click_on 'Continue'

    click_on 'Continue'
  end

  def when_the_provider_changes_the_length_of_the_ske_course
    length_row = page.find('.govuk-summary-list__key', text: 'Length').find(:xpath, '..')

    within length_row do
      click_on 'Change'
    end

    expect(page).to have_content('How long must their SKE course be?')
    choose '12 weeks'
    click_on 'Continue'
  end

  def then_the_provider_should_be_taken_to_the_offer_summary_page
    expect(page).to have_content('Check and send offer')
    expect(page).to have_content('Conditions of offer')
  end

  def and_the_conditions_should_be_displayed
    expect(page).to have_content('Subject knowledge enhancement course')
    expect(page).to have_content("Subject\n#{@subject.name}")
    expect(page).to have_content("Length\n16 weeks")
    expect(page).to have_content("Reason\nTheir degree subject was not #{@subject.name}")
  end
end

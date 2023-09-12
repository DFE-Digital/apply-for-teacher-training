require 'rails_helper'

RSpec.feature 'Emails are suppressed in Sandbox' do
  include CourseOptionHelpers
  include DfESignInHelpers

  around do |example|
    old_references = CycleTimetable.apply_opens(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR)
    travel_temporarily_to(old_references) { example.run }
  end

  it 'when a candidate triggers a notification', :sandbox, :sidekiq do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_and_receive_notifications_for_my_provider
    and_an_application_choice_with_an_offer_exists_for_the_provider

    when_a_user_accepts_the_offer
    then_i_should_not_get_an_email

    when_i_sign_in_to_the_provider_interface
    and_i_visit_the_application
    then_i_should_see_the_email_in_the_email_log
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_and_receive_notifications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def and_an_application_choice_with_an_offer_exists_for_the_provider
    course_option = course_option_for_provider_code(provider_code: 'ABC')
    @application_choice = create(:application_choice, :offered, course_option:)
  end

  def when_a_user_accepts_the_offer
    # cheating as I do not want to touch the candidate UI
    AcceptOffer.new(application_choice: @application_choice).save!
  end

  def then_i_should_not_get_an_email
    open_email('provider@example.com')
    expect(current_email).to be_nil
  end

  def when_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def and_i_visit_the_application
    visit provider_interface_application_choice_path(
      @application_choice.id,
    )
  end

  def then_i_should_see_the_email_in_the_email_log
    within('[data-qa="sub-navigation"]') do
      click_link 'Emails (Sandbox only)'
    end

    expect(page).to have_content("accepted your offer for #{@application_choice.current_course.name}")
  end
end

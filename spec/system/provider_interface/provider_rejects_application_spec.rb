require 'rails_helper'

RSpec.feature 'Provider rejects application' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_awaiting_provider_decision) {
    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder'))
  }

  scenario 'Provider rejects application' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider

    when_i_respond_to_an_application
    and_i_choose_to_reject_it
    then_i_see_some_application_info

    when_i_add_a_rejection_reason
    and_i_click_to_continue
    then_i_am_asked_to_confirm_the_rejection

    when_i_confirm_the_rejection
    then_i_am_back_to_the_application_page
    and_i_can_see_the_application_has_just_been_rejected
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    provider_user_exists_in_apply_database
  end

  def when_i_respond_to_an_application
    visit provider_interface_application_choice_respond_path(
      application_awaiting_provider_decision.id,
    )
  end

  def and_i_choose_to_reject_it
    choose 'Reject application'
    click_on 'Continue'
  end

  def then_i_see_some_application_info
    expect(page).to have_content \
      application_awaiting_provider_decision.course.name_and_code
    expect(page).to have_content \
      application_awaiting_provider_decision.application_form.first_name
    expect(page).to have_content \
      application_awaiting_provider_decision.application_form.last_name
  end

  def when_i_add_a_rejection_reason
    fill_in('Tell the candidate why their application was rejected', with: 'A rejection reason')
  end

  def and_i_click_to_continue
    click_on 'Continue'
  end

  def then_i_am_asked_to_confirm_the_rejection
    expect(page).to have_current_path(
      provider_interface_application_choice_confirm_reject_path(
        application_awaiting_provider_decision.id,
      ),
    )
  end

  def when_i_confirm_the_rejection
    click_on 'Confirm rejection'
  end

  def then_i_am_back_to_the_application_page
    expect(page).to have_current_path(
      provider_interface_application_choice_path(
        application_awaiting_provider_decision.id,
      ),
    )
  end

  def and_i_can_see_the_application_has_just_been_rejected
    expect(page).to have_content 'Application status changed to ‘Rejected’'
  end
end

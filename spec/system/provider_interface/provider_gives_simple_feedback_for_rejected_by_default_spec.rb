require 'rails_helper'

RSpec.feature 'Provider gives feedback for application rejected by default when Structured reasons for rejection on RBD is deactivated' do
  include CourseOptionHelpers
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_rejected_by_default) do
    create(:application_choice, :with_rejection_by_default, course_option: course_option, application_form: create(:completed_application_form, first_name: 'Alice', last_name: 'Wunder'))
  end

  scenario 'Provider gives feedback for application rejected by default' do
    FeatureFlag.deactivate(:structured_reasons_for_rejection_on_rbd)

    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_i_am_permitted_to_make_decisions_on_applications_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_an_application_that_was_rejected_by_default
    and_i_choose_to_give_feedback
    and_i_add_a_rejection_reason
    and_i_click_to_continue
    and_i_check_and_send_my_feedback

    then_i_am_back_to_the_application_page
    and_i_can_see_the_feedback_provided
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

  def when_i_visit_an_application_that_was_rejected_by_default
    visit provider_interface_application_choice_path(
      application_rejected_by_default.id,
    )
  end

  def and_i_choose_to_give_feedback
    click_on 'Give feedback'
  end

  def and_i_add_a_rejection_reason
    fill_in('Feedback for candidate', with: 'The course became full.')
  end

  def and_i_click_to_continue
    click_on t('continue')
  end

  def and_i_check_and_send_my_feedback
    expect(page).to have_content 'Check and send feedback'
    expect(page).to have_content 'The course became full.'
    expect(page).to have_link 'Change'

    click_on 'Send feedback'
  end

  def then_i_am_back_to_the_application_page
    expect(page).to have_current_path(
      provider_interface_application_choice_path(application_rejected_by_default.id),
    )
  end

  def and_i_can_see_the_feedback_provided
    expect(application_rejected_by_default.reload.reject_by_default_feedback_sent_at).not_to be_nil
    expect(page).to have_content 'Rejection details'
    expect(page).to have_content 'Automatically rejected'
    expect(page).to have_content application_rejected_by_default.rejected_at.to_s(:govuk_date)
    expect(page).to have_content 'Feedback sent'
    expect(page).to have_content application_rejected_by_default.reject_by_default_feedback_sent_at.to_s(:govuk_date)
    expect(page).to have_content 'The course became full.'
  end
end

require 'rails_helper'

RSpec.describe 'Provider unsuccessfully attempts to create a withdrawal request' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :full_time, provider:) }
  let(:course_option) { build(:course_option, course:) }
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           application_form:,
           course_option:)
  end

  before do
    FeatureFlag.activate(:new_withdrawal_on_behalf_of_candidate_flow)
  end

  scenario 'Provider user views errors when trying to submit form', time: mid_cycle do
    given_i_can_make_decisions_on_applications
    and_i_am_reviewing_a_submitted_application
    and_i_click_on('Withdraw at candidate’s request')
    when_i_click_on('Continue')
    then_i_see_the_error('Select a reason for withdrawing this application on behalf of the candidate')

    when_i_select('Other')
    and_i_click_on('Continue')
    then_i_see_the_error('Enter details to explain the reason for withdrawing this application on behalf of the candidate')

    when_i_enter_details_over_200_words
    and_i_click_on('Continue')
    then_i_see_the_error('Details must be 200 words or fewer')

    when_i_click_on('Back')
    then_i_see_the_application_choice_page
  end

  scenario 'Provider tries to create a withdrawal request for an application they do not have permission to view' do
    given_i_can_make_decisions_on_applications
    when_i_visit_the_withdrawal_requests_path_for_an_application_choice_i_cannot_view
    then_i_see_an_error_page
  end

private

  def given_i_can_make_decisions_on_applications
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    permit_make_decisions!
  end

  def and_i_am_reviewing_a_submitted_application
    provider_signs_in_using_dfe_sign_in
    click_on 'Applications'
    click_on application_form.full_name
  end

  def and_i_click_on(string)
    click_on string
  end
  alias_method :when_i_click_on, :and_i_click_on

  def when_i_select(string)
    choose string
  end

  def then_i_see_the_application_choice_page
    expect(page).to have_text application_form.full_name
    expect(page).to have_current_path(provider_interface_application_choice_path(application_choice))
  end

  def when_i_enter_details_over_200_words
    fill_in 'Details', with: ('ab ' * 201)
  end

  def then_i_see_the_error(string)
    within 'div.govuk-error-summary' do
      expect(page).to have_text string
    end
    within 'fieldset.govuk-fieldset' do
      expect(page).to have_text string
    end
  end

  def when_i_visit_the_withdrawal_requests_path_for_an_application_choice_i_cannot_view
    new_course = build(:course, :full_time)
    new_application_choice = create(:application_choice, :awaiting_provider_decision, course_option: build(:course_option, course: new_course))
    provider_signs_in_using_dfe_sign_in
    click_on 'Applications'
    visit new_provider_interface_withdrawal_request_path(new_application_choice)
  end

  def then_i_see_an_error_page
    expect(page).to have_text 'Page not found'
  end
end

require 'rails_helper'

RSpec.feature 'Provider makes an offer' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:application_form) { build(:application_form, :minimum_info) }
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           application_form: application_form,
           course_option: course_option)
  end
  let(:course) { build(:course, :open_on_apply, provider: provider) }
  let(:course_option) { build(:course_option, course: course) }

  before do
    FeatureFlag.activate(:updated_offer_flow)
  end

  scenario 'Making an offer for the requested course option' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_awaiting_decision
    and_i_click_on_make_decision
    then_i_see_the_decision_page

    when_i_choose_to_make_an_offer
    then_the_conditions_page_is_loaded
    and_the_default_conditions_are_checked

    when_i_add_further_conditions
    and_i_click_continue
    then_the_review_page_is_loaded
    and_i_can_confirm_my_answers

    given_the_course_has_multiple_course_options
    when_i_click_change_location
    then_i_am_taken_to_the_change_location_page

    when_i_select_a_new_location
    and_i_click_continue

    #common steps, will be repeated every time we go back
    then_the_conditions_page_is_loaded
    and_i_click_continue
    then_the_review_page_is_loaded
    and_i_can_confirm_the_new_location_selection

    when_i_send_the_offer
    then_i_see_that_the_offer_was_successfuly_made
  end

  def given_i_am_a_provider_user
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_an_application_choice_awaiting_decision
    click_on application_choice.application_form.full_name
  end

  def and_i_click_on_make_decision
    click_on 'Make decision'
  end

  def then_i_see_the_decision_page
    expect(page).to have_content('Make a decision')
    expect(page).to have_content('Course applied for')
  end

  def when_i_choose_to_make_an_offer
    choose 'Make an offer'
    and_i_click_continue
  end

  def then_the_conditions_page_is_loaded
    expect(page).to have_content('Conditions of offer')
  end

  def and_the_default_conditions_are_checked
    expect(find("input[value='Fitness to train to teach check']")).to be_checked
    expect(find("input[value='Disclosure and Barring Service (DBS) check']")).to be_checked
  end

  def when_i_add_further_conditions
    fill_in('provider_interface_offer_wizard[further_condition_1]', with: 'A* on Maths A Level')
  end

  def and_i_click_continue
    click_on t('continue')
  end

  def then_the_review_page_is_loaded
    expect(page).to have_content('Check and send offer')
  end

  def and_i_can_confirm_my_answers
    within('.app-offer-panel') do
      expect(page).to have_content('A* on Maths A Level')
    end
  end

  def given_the_course_has_multiple_course_options
    course_options = create_list(:course_option, 3, course: course)
    @selected_course_option = course_options.sample
  end

  def when_i_click_change_location
    within(:xpath, "////div[@class='govuk-summary-list__row'][3]") do
      click_on 'Change'
    end
  end

  def then_i_am_taken_to_the_change_location_page
    expect(page).to have_content('Select location')
  end

  def when_i_select_a_new_location
    choose @selected_course_option.site_name
  end

  def and_i_can_confirm_the_new_location_selection
    within(:xpath, "////div[@class='govuk-summary-list__row'][3]") do
      expect(page).to have_content(@selected_course_option.site.name_and_address)
    end
  end

  def when_i_send_the_offer
    click_on 'Send offer'
  end

  def then_i_see_that_the_offer_was_successfuly_made
    within('.govuk-notification-banner--success') do
      expect(page).to have_content('Offer sent')
    end
  end
end

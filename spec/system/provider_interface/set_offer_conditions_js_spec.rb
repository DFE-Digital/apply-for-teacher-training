require 'rails_helper'

RSpec.describe 'Provider makes an offer with JS enabled', js: true do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:ratifying_provider) { create(:provider) }

  let(:application_form) { build(:application_form, :minimum_info) }
  let(:course) { build(:course, :open_on_apply, provider: provider, accredited_provider: ratifying_provider) }
  let(:course_option) { build(:course_option, course: course) }

  scenario 'Setting offer conditions' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    given_there_is_an_application_to_a_course_i_can_make_decisions_on

    when_i_make_an_offer_on_an_application_choice
    then_the_conditions_page_is_loaded
    and_the_default_conditions_are_checked

    when_i_add_a_further_condition(text: 'Be cool', index: 0)
    and_i_add_another_further_condition(text: 'Win an olympic medal', index: 1)
    and_i_add_another_further_condition(text: 'Show us a photo of your dog', index: 2)
    and_i_add_another_further_condition(text: 'Wear a tie', index: 3)
    and_i_remove_the_second_condition
    then_the_condition_inputs_are_rendered_correctly

    when_i_click_continue
    then_the_review_page_is_loaded
    and_the_conditions_are_displayed(['Be cool', 'Show us a photo of your dog', 'Wear a tie'])

    when_i_click_change_conditions
    then_the_conditions_page_is_loaded

    when_i_remove_the_second_condition
    then_the_condition_inputs_are_rendered_correctly

    when_i_click_continue
    then_the_review_page_is_loaded
    and_the_conditions_are_displayed(['Be cool', 'Wear a tie'])
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

  def given_there_is_an_application_to_a_course_i_can_make_decisions_on
    create(
      :provider_relationship_permissions,
      training_provider: provider,
      ratifying_provider: ratifying_provider,
    )
    create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: application_form,
      course_option: course_option,
    )
  end

  def when_i_make_an_offer_on_an_application_choice
    visit provider_interface_applications_path
    click_on application_form.full_name
    click_on 'Make decision'
    expect(page).to have_content('Make a decision')
    expect(page).to have_content('Course applied for')
    choose('Make an offer', visible: false)
    and_i_click_continue
  end

  def then_the_conditions_page_is_loaded
    expect(page).to have_content('Conditions of offer')
    expect(page).to have_content('Standard conditions')
    expect(page).to have_content('Further conditions')
  end

  def and_the_default_conditions_are_checked
    expect(find("input[value='Fitness to train to teach check']", visible: false)).to be_checked
    expect(find("input[value='Disclosure and Barring Service (DBS) check']", visible: false)).to be_checked
  end

  def when_i_add_a_further_condition(text:, index:)
    click_on 'Add another condition'
    fill_in("provider_interface_offer_wizard[further_conditions][#{index}][text]", with: text)
    expect(page.current_url).not_to include("#provider-interface-offer-wizard-further-conditions-#{index}-text-field")
  end

  alias_method :and_i_add_another_further_condition, :when_i_add_a_further_condition

  def when_i_remove_the_second_condition
    click_on 'Remove condition 2'
  end

  alias_method :and_i_remove_the_second_condition, :when_i_remove_the_second_condition

  def then_the_condition_inputs_are_rendered_correctly
    condition_fields = all('.app-add-another__item')
    condition_fields.each_with_index do |field, index|
      expect(field.find('label')).to have_content("Condition #{index + 1}")
      expect(field.find('.govuk-visually-hidden')).to have_content("condition #{index + 1}")
    end
  end

  def when_i_click_continue
    click_on t('continue')
  end

  alias_method :and_i_click_continue, :when_i_click_continue

  def then_the_review_page_is_loaded
    expect(page).to have_content('Check and send offer')
  end

  def and_the_conditions_are_displayed(conditions)
    expected_conditions = [
      'Fitness to train to teach check',
      'Disclosure and Barring Service (DBS) check',
    ] + conditions

    within('.app-offer-panel') do
      expect(all('.conditions-row > td:first-child').map(&:text)).to eq expected_conditions
    end
  end

  def when_i_click_change_conditions
    click_on 'Add or change conditions'
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

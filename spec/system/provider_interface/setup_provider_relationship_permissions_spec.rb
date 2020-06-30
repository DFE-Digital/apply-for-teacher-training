require 'rails_helper'

RSpec.feature 'Setting up provider relationship permissions' do
  include DfESignInHelpers

  scenario 'Provider user sets up permissions for their organisation' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_provider_permissions_feature_is_enabled
    and_i_can_manage_organisations
    and_my_organisations_have_not_had_permissions_setup

    when_i_sign_in_to_the_provider_interface
    then_i_can_see_the_permissions_setup_page

    when_i_click_continue
    and_i_choose_permissions_for_the_provider_relationship
    and_i_confirm_my_choices
    then_i_see_permissions_were_successfully_saved

    when_i_click_continue
    then_i_can_see_the_permissions_setup_page

    when_i_click_continue
    and_i_choose_permissions_for_another_provider_relationship
    and_i_confirm_my_choices_again
    then_i_see_permissions_were_successfully_saved

    when_i_click_continue
    then_i_can_see_candidate_applications
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_the_provider_permissions_feature_is_enabled
    FeatureFlag.activate('enforce_provider_to_provider_permissions')
  end

  def and_i_can_manage_organisations
    @provider_user = ProviderUser.last
    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = Provider.find_by(code: 'DEF')

    @another_training_provider = create(:provider, :with_signed_agreement)
    @another_ratifying_provider = create(:provider, :with_signed_agreement)
    @provider_user.providers << @another_training_provider
    @provider_user.provider_permissions.update_all(manage_organisations: true)
  end

  def and_my_organisations_have_not_had_permissions_setup
    create(
      :accredited_body_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
    )

    create(
      :training_provider_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
    )

    create(
      :accredited_body_permissions,
      ratifying_provider: @another_ratifying_provider,
      training_provider: @another_training_provider,
    )

    create(
      :training_provider_permissions,
      ratifying_provider: @another_ratifying_provider,
      training_provider: @another_training_provider,
    )
  end

  alias_method :when_i_sign_in_to_the_provider_interface, :and_i_sign_in_to_the_provider_interface

  def then_i_can_see_the_permissions_setup_page
    expect(page).to have_content('Set up permissions for your organisation')
  end

  def when_i_click_continue
    click_on 'Continue'
  end

  def and_i_choose_permissions_for_the_provider_relationship
    expect(page).to have_content("For courses run by #{@training_provider.name} and ratified by #{@ratifying_provider.name}")

    within(find('.training-provider')) do
      check 'They have access to safeguarding information'
    end

    click_on 'Continue'
  end

  def and_i_confirm_my_choices
    expect(page).to have_content("#{@training_provider.name} can:\nview applications see safeguarding information")
    expect(page).to have_content("#{@ratifying_provider.name} can:\nview applications")

    click_on 'Save permissions'
  end

  def then_i_see_permissions_were_successfully_saved
    expect(page).to have_content('Permissions successfully set up')
  end

  def and_i_choose_permissions_for_another_provider_relationship
    expect(page).to have_content("For courses run by #{@another_training_provider.name} and ratified by #{@another_ratifying_provider.name}")

    within(find('.accredited-body')) do
      check 'They have access to safeguarding information'
    end

    click_on 'Continue'
  end

  def and_i_confirm_my_choices_again
    expect(page).to have_content("#{@another_training_provider.name} can:\nview applications\n#{@another_ratifying_provider.name}")
    expect(page).to have_content("#{@another_ratifying_provider.name} can:\nview applications see safeguarding information")

    click_on 'Save permissions'
  end

  def then_i_can_see_candidate_applications
    expect(page).to have_css('h1.govuk-heading-xl', text: 'Applications')
  end
end

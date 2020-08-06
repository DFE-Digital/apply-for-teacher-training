require 'rails_helper'

RSpec.feature 'Setting up provider relationship permissions' do
  include DfESignInHelpers

  scenario 'Provider user sets up permissions for their organisation' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_provider_permissions_feature_is_enabled
    and_i_can_manage_organisations
    and_my_organisations_have_not_had_permissions_setup

    when_i_sign_in_to_the_provider_interface
    then_i_can_see_the_organisations_needing_permissions_setup

    when_i_click_continue
    then_i_can_see_general_information_about_permissions

    when_i_click_continue
    then_i_can_see_the_permissions_setup_page

    when_i_choose_permissions_for_the_first_provider_relationship
    and_i_choose_permissions_for_the_next_provider_relationship
    then_i_can_see_the_permissions_summary_page

    when_i_change_permissions_for_the_first_provider_relationship
    then_i_return_to_the_permissions_summary_page

    when_i_confirm_the_updated_permissions
    then_i_see_permissions_setup_has_finished

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
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
      training_provider_can_make_decisions: false,
      training_provider_can_view_safeguarding_information: false,
      setup_at: nil,
    )

    create(
      :provider_relationship_permissions,
      ratifying_provider: @another_ratifying_provider,
      training_provider: @another_training_provider,
      training_provider_can_make_decisions: false,
      training_provider_can_view_safeguarding_information: false,
      setup_at: nil,
    )
  end

  alias_method :when_i_sign_in_to_the_provider_interface, :and_i_sign_in_to_the_provider_interface

  def then_i_can_see_the_organisations_needing_permissions_setup
    expect(page).to have_content('Set up permissions for your organisation')
    expect(page).to have_content('The organisations you’ll need to set up')
    expect(page).to have_content(@training_provider.name)
    expect(page).to have_content(@ratifying_provider.name)
    expect(page).to have_content(@another_training_provider.name)
    expect(page).to have_content(@another_ratifying_provider.name)
  end

  def when_i_click_continue
    click_on 'Continue'
  end

  alias_method :and_i_click_continue, :when_i_click_continue

  def then_i_can_see_general_information_about_permissions
    expect(page).to have_content('Understanding access and permissions')
    expect(page).to have_content('Access to applications')
    expect(page).to have_content('Permission to make decisions')
    expect(page).to have_content('Permission to view safeguarding information')
  end

  def then_i_can_see_the_permissions_setup_page
    expect(page).to have_content("For courses run by #{@training_provider.name} and ratified by #{@ratifying_provider.name}")
  end

  def when_i_choose_permissions_for_the_first_provider_relationship
    within(find('.make-decisions')) { check @training_provider.name }
    within(find('.view-safeguarding-information')) { check @training_provider.name }

    click_on 'Continue'
  end

  def and_i_choose_permissions_for_the_next_provider_relationship
    expect(page).to have_content("For courses run by #{@another_training_provider.name} and ratified by #{@another_ratifying_provider.name}")

    within(find('.make-decisions')) { check @another_ratifying_provider.name }
    within(find('.view-safeguarding-information')) { check @another_ratifying_provider.name }

    click_on 'Continue'
  end

  def then_i_can_see_the_permissions_summary_page
    expect(page).to have_content(
      [
        "For courses run by #{@training_provider.name} and ratified by #{@ratifying_provider.name}",
        'Which organisations can make decisions?',
        @training_provider.name,
        'Change',
        'Which organisations can view safeguarding information?',
        @training_provider.name,
      ].join("\n"),
    )

    expect(page).to have_content(
      [
        "For courses run by #{@another_training_provider.name} and ratified by #{@another_ratifying_provider.name}",
        'Which organisations can make decisions?',
        @another_ratifying_provider.name,
        'Change',
        'Which organisations can view safeguarding information?',
        @another_ratifying_provider.name,
      ].join("\n"),
    )
  end

  def when_i_confirm_the_updated_permissions
    expect(page).to have_content(
      [
        "For courses run by #{@training_provider.name} and ratified by #{@ratifying_provider.name}",
        'Which organisations can make decisions?',
        "#{@training_provider.name} #{@ratifying_provider.name}",
        'Change',
        'Which organisations can view safeguarding information?',
        @training_provider.name,
      ].join("\n"),
    )

    expect(page).to have_content(
      [
        "For courses run by #{@another_training_provider.name} and ratified by #{@another_ratifying_provider.name}",
        'Which organisations can make decisions?',
        @another_ratifying_provider.name,
        'Change',
        'Which organisations can view safeguarding information?',
        @another_ratifying_provider.name,
      ].join("\n"),
    )

    click_on 'Save permissions'
  end

  def when_i_change_permissions_for_the_first_provider_relationship
    click_on 'Change', match: :first

    within(find('.make-decisions')) { check @ratifying_provider.name }
    click_on 'Continue'
  end

  def then_i_return_to_the_permissions_summary_page
    expect(page).to have_content("Which organisations can make decisions?\n#{@training_provider.name} #{@ratifying_provider.name}\n")
  end

  def then_i_see_permissions_setup_has_finished
    expect(page).to have_content('Permissions successfully set up')
  end

  def then_i_can_see_candidate_applications
    expect(page).to have_css('h1.govuk-heading-xl', text: 'Applications')
  end
end

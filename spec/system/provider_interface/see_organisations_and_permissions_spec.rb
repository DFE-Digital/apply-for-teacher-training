require 'rails_helper'

RSpec.feature 'See organisation permissions' do
  include DfESignInHelpers

  scenario 'A provider user views the organisations they belong to' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_provider_permissions_feature_is_enabled
    and_i_can_manage_organisations_for_a_provider
    and_the_provider_has_courses_ratified_by_another_provider
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_organisations_page
    then_i_can_see_provider_organisations_i_belong_to

    when_i_click_on_a_ratifying_provider_organisation
    then_i_can_see_permissions_for_the_ratifying_provider

    when_i_visit_the_provider_organisations_page
    and_i_click_on_a_training_provider_organisation
    then_i_can_see_permissions_for_the_training_provider
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_the_provider_permissions_feature_is_enabled
    FeatureFlag.activate('enforce_provider_to_provider_permissions')
  end

  def and_i_can_manage_organisations_for_a_provider
    @provider_user = ProviderUser.last
    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = Provider.find_by(code: 'DEF')
    @unmanageable_provider = create(:provider, :with_signed_agreement)
    @provider_user.providers << @unmanageable_provider
    @provider_user.provider_permissions.update_all(manage_organisations: true)
  end

  def and_the_provider_has_courses_ratified_by_another_provider
    create(
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
      training_provider_can_make_decisions: false,
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      training_provider_can_view_safeguarding_information: false,
      setup_at: Time.zone.now,
    )
  end

  def when_i_visit_the_provider_organisations_page
    click_on 'Organisations'
  end

  def then_i_can_see_provider_organisations_i_belong_to
    expect(page).to have_link(@training_provider.name)
    expect(page).to have_link(@ratifying_provider.name)
    expect(page).not_to have_link(@unmanageable_provider.name)
  end

  def when_i_click_on_a_ratifying_provider_organisation
    click_on @ratifying_provider.name
  end

  def then_i_can_see_permissions_for_the_ratifying_provider
    expect(page).to have_content("For courses ratified by #{@ratifying_provider.name} and run by #{@training_provider.name}")
    expect(page).to have_content("The following organisation(s) can see safeguarding information:\n#{@ratifying_provider.name}")
  end

  def and_i_can_see_permissions_for_the_training_provider
    expect(page).to have_content('The following organisation(s) can only view applications:')
  end

  def and_i_click_on_a_training_provider_organisation
    click_on @training_provider.name
  end

  def then_i_can_see_permissions_for_the_training_provider
    expect(page).to have_content("For courses run by #{@training_provider.name} and ratified by #{@ratifying_provider.name}")
    expect(page).to have_content("The following organisation(s) can only view applications:\n#{@training_provider.name}")

    expect(page).to have_link('Change', href: provider_interface_edit_provider_relationship_permissions_path(
      ratifying_provider_id: @ratifying_provider.id, training_provider_id: @training_provider.id,
    ))
  end

  def and_i_can_see_permissions_for_the_ratifying_provider
    expect(page).to have_content("The following organisation(s) can see safeguarding information: \n#{@training_provider.name}")
  end
end

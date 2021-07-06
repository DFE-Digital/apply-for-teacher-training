require 'rails_helper'

RSpec.feature 'See organisation permissions' do
  include DfESignInHelpers

  scenario 'A provider user views the organisations they belong to' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_the_accredited_provider_setting_permissions_flag_is_inactive
    and_i_can_manage_organisations_for_a_provider
    and_the_provider_has_courses_ratified_by_another_provider
    and_the_ratifying_provider_has_courses_run_by_another_provider
    and_the_ratifying_provider_has_courses_run_by_unmanagable_providers
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_provider_organisations_page
    then_i_can_see_provider_organisations_i_belong_to

    when_i_click_on_a_ratifying_provider_organisation
    then_i_can_see_permissions_for_the_ratifying_provider

    when_i_visit_the_provider_organisations_page
    and_i_click_on_a_training_provider_organisation
    and_i_can_not_see_permissions_for_unassociated_providers
    then_i_can_see_permissions_for_the_training_provider
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database
  end

  def and_i_can_manage_organisations_for_a_provider
    @provider_user = ProviderUser.last
    @training_provider = Provider.find_by(code: 'ABC')
    @ratifying_provider = Provider.find_by(code: 'DEF')
    @unmanageable_provider = create(:provider, :with_signed_agreement)
    @another_training_provider = create(:provider, :with_signed_agreement)
    @provider_user.providers << @unmanageable_provider
    @provider_user.providers << @another_training_provider
    @provider_user.provider_permissions.update_all(manage_organisations: true)
  end

  def and_the_provider_has_courses_ratified_by_another_provider
    @permissions = create(
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @training_provider,
      training_provider_can_make_decisions: false,
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      training_provider_can_view_safeguarding_information: false,
      ratifying_provider_can_view_diversity_information: true,
      training_provider_can_view_diversity_information: false,
      setup_at: Time.zone.now,
    )
  end

  def and_the_ratifying_provider_has_courses_run_by_another_provider
    create(
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @another_training_provider,
      training_provider_can_make_decisions: false,
      ratifying_provider_can_make_decisions: true,
      ratifying_provider_can_view_safeguarding_information: true,
      training_provider_can_view_safeguarding_information: false,
      ratifying_provider_can_view_diversity_information: true,
      training_provider_can_view_diversity_information: false,
      setup_at: Time.zone.now,
    )
  end

  def and_the_ratifying_provider_has_courses_run_by_unmanagable_providers
    @unmanageable_training_provider = create(:provider)
    create(
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @unmanageable_training_provider,
      training_provider_can_make_decisions: false,
      training_provider_can_view_safeguarding_information: false,
      training_provider_can_view_diversity_information: false,
      setup_at: nil,
    )
    @another_unmanageable_training_provider = create(:provider)
    create(
      :provider_relationship_permissions,
      ratifying_provider: @ratifying_provider,
      training_provider: @another_unmanageable_training_provider,
      setup_at: Time.zone.now,
    )
  end

  def when_i_visit_the_provider_organisations_page
    visit provider_interface_path
    click_on(t('page_titles.provider.account'))
    click_on(t('page_titles.provider.org_permissions'))
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
    expect(page).to have_content('Who can view safeguarding information?')

    expect(page).to have_content("#{@unmanageable_training_provider.name} have not set up permissions yet - only they can set up permissions. Contact them to do this.")
  end

  def and_i_can_see_permissions_for_the_training_provider
    expect(page).to have_content("#{@training_provider.name} and #{@ratifying_provider.name} ")
    expect(page).not_to have_content("#{@ratifying_provider.name} and #{@training_provider.name} ")
    expect(page).to have_content("#{@training_provider.name} can only view applications.")
    expect(page).to have_link('Change', href: provider_interface_edit_provider_relationship_permissions_path(@permissions))
  end

  def and_i_click_on_a_training_provider_organisation
    click_on @training_provider.name
  end

  def then_i_can_see_permissions_for_the_training_provider
    expect(page).to have_content("#{@training_provider.name} and #{@ratifying_provider.name}")

    expect(page).to have_link(
      'Change which organisations can make decisions for courses run by Example Provider and ratified by Another Provider',
      href: Regexp.new(provider_interface_edit_provider_relationship_permissions_path(@permissions)),
    )
  end

  def and_i_can_not_see_permissions_for_unassociated_providers
    expect(page).not_to have_content("#{@another_training_provider.name} and #{@ratifying_provider.name} ")
    expect(page).not_to have_content("#{@another_training_provider.name} can only view applications.")
  end

  def and_i_can_see_permissions_for_the_ratifying_provider
    expect(page).to have_content("The following organisation(s) can view safeguarding information: \n#{@training_provider.name}")
  end

  def and_the_accredited_provider_setting_permissions_flag_is_inactive
    FeatureFlag.deactivate(:accredited_provider_setting_permissions)
  end
end

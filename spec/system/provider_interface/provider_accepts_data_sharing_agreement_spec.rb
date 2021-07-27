require 'rails_helper'

RSpec.feature 'Accept data sharing agreement' do
  include DfESignInHelpers

  scenario 'Provider user cannot access provider_interface without a data sharing agreement in place' do
    given_i_am_an_authorised_provider_user
    and_no_data_sharing_agreement_for_my_provider_has_been_accepted
    when_i_navigate_to_the_provider_interface
    then_i_am_redirected_to_the_data_sharing_agreement_pages
  end

  scenario 'Provider user accepts the data sharing agreement' do
    given_i_am_an_authorised_provider_user
    and_no_data_sharing_agreement_for_my_provider_has_been_accepted
    and_i_am_presented_with_a_data_sharing_agreement
    and_i_cannot_navigate_to_pages_i_do_not_have_access_to
    when_i_agree_to_the_data_sharing_agreement
    then_i_can_see_the_data_sharing_agreement_success_page
    then_i_can_navigate_to_the_provider_interface
  end

  scenario 'Provider user agrees to multiple data sharing agreements' do
    given_i_am_an_authorised_provider_user
    and_no_data_sharing_agreements_for_any_of_my_providers_exist
    when_i_navigate_to_the_provider_interface
    then_i_am_redirected_to_the_data_sharing_agreement_pages
    when_i_agree_to_the_data_sharing_agreement
    then_i_am_redirected_to_the_data_sharing_agreement_pages
    when_i_agree_to_the_data_sharing_agreement_again
    then_i_can_see_the_data_sharing_agreement_success_page
    then_i_can_navigate_to_the_provider_interface
  end

  scenario 'Provider user with an organisation to set up accepts the data sharing agreement' do
    given_i_am_an_authorised_provider_user
    and_no_data_sharing_agreement_for_my_provider_has_been_accepted
    and_i_need_to_set_up_organisation_permissions
    and_i_am_presented_with_a_data_sharing_agreement
    and_i_cannot_navigate_to_pages_i_do_not_have_access_to
    when_i_agree_to_the_data_sharing_agreement
    then_i_can_see_the_data_sharing_agreement_success_page_with_organisation_setup_steps
    and_i_can_proceed_to_set_up_organisation_permissions
  end

  def given_i_am_an_authorised_provider_user
    provider_user_exists_in_apply_database
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def and_no_data_sharing_agreement_for_my_provider_has_been_accepted
    provider = Provider.find_by_code('ABC')
    ProviderAgreement.data_sharing_agreements.for_provider(provider).destroy_all
  end

  def and_no_data_sharing_agreements_for_any_of_my_providers_exist
    provider_user = ProviderUser.find_by_dfe_sign_in_uid 'DFE_SIGN_IN_UID'
    provider1 = Provider.find_by_code('ABC')
    provider2 = create(:provider, code: 'CBA', name: 'Another Provider')
    provider2.provider_users << provider_user
    ProviderAgreement.data_sharing_agreements.for_provider(provider1).destroy_all
    ProviderAgreement.data_sharing_agreements.for_provider(provider2).destroy_all
  end

  def and_i_need_to_set_up_organisation_permissions
    provider_user = ProviderUser.find_by_dfe_sign_in_uid 'DFE_SIGN_IN_UID'
    provider = Provider.find_by_code('ABC')
    ratifying_provider = create(:provider, :with_signed_agreement)
    ratifying_provider.provider_users << provider_user
    create(:course, :open_on_apply, provider: provider, accredited_provider: ratifying_provider)
    provider_user.provider_permissions.where(provider: provider).update_all(manage_organisations: true)
    create(:provider_relationship_permissions, setup_at: nil, training_provider: provider, ratifying_provider: ratifying_provider)
  end

  def when_i_navigate_to_the_provider_interface
    visit provider_interface_applications_path
  end

  def then_i_am_redirected_to_the_data_sharing_agreement_pages
    expect(page).to have_current_path provider_interface_new_data_sharing_agreement_path
  end

  def and_i_am_presented_with_a_data_sharing_agreement
    visit provider_interface_new_data_sharing_agreement_path
  end

  def when_i_agree_to_the_data_sharing_agreement
    check 'Example Provider agrees to comply with the data sharing practices outlined in this agreement', allow_label_click: true
    click_on t('continue')
  end

  def when_i_agree_to_the_data_sharing_agreement_again
    check 'Another Provider agrees to comply with the data sharing practices outlined in this agreement', allow_label_click: true
    click_on t('continue')
  end

  def then_i_can_see_the_data_sharing_agreement_success_page
    expect(page).to have_content('Data sharing agreement signed')
    expect(page).to have_link('view applications')
  end

  def then_i_can_see_the_data_sharing_agreement_success_page_with_organisation_setup_steps
    expect(page).to have_content('Data sharing agreement signed')
    expect(page).to have_content('Either you or your partner organisations must set up organisation permissions')
    expect(page).to have_link('Continue')
  end

  def then_i_can_navigate_to_the_provider_interface
    click_on 'view applications'
    expect(page).to have_current_path provider_interface_applications_path
  end

  def and_i_cannot_navigate_to_pages_i_do_not_have_access_to
    expect(page).to have_link 'Sign out'
    expect(page).not_to have_link 'Organisations'
    expect(page).not_to have_link 'Users'
    expect(page).not_to have_link 'Account'
    expect(page).not_to have_link 'Applications'
  end

  def and_i_can_proceed_to_set_up_organisation_permissions
    click_on 'Continue'

    expect(page).to have_content('Set up organisation permissions')
  end
end

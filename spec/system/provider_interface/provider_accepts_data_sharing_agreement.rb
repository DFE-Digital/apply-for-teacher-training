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
    when_i_agree_to_the_data_sharing_agreement
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
    then_i_can_navigate_to_the_provider_interface
  end

  def given_i_am_an_authorised_provider_user
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
    provider_user_exists_in_apply_database
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
    click_on 'Continue'
  end

  def when_i_agree_to_the_data_sharing_agreement_again
    check 'Another Provider agrees to comply with the data sharing practices outlined in this agreement', allow_label_click: true
    click_on 'Continue'
  end

  def then_i_can_navigate_to_the_provider_interface
    expect(page).to have_current_path provider_interface_applications_path
  end
end

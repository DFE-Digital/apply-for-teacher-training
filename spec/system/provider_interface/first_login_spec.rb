require 'rails_helper'

RSpec.feature 'See applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:pre_approved_provider_user) do
    provider = create(:provider, code: 'ABC')
    create(:provider_user, providers: [provider], dfe_sign_in_uid: nil)
  end

  scenario 'Provider user can access interface immediately if pre-approved' do
    given_a_support_user_has_pre_approved_my_email_address
    and_i_am_a_new_provider_user_authenticated_with_dfe_sign_in

    when_i_visit_the_provider_page

    then_i_should_be_on_the_applications_page
    and_my_dfe_sign_in_uid_has_been_stored
  end

  def given_a_support_user_has_pre_approved_my_email_address
    pre_approved_provider_user
  end

  def and_i_am_a_new_provider_user_authenticated_with_dfe_sign_in
    email_address = pre_approved_provider_user.email_address
    user_exists_in_dfe_sign_in(email_address: email_address, dfe_sign_in_uid: 'NEW_UID')
    provider_signs_in_using_dfe_sign_in
  end

  def then_i_should_see_the_account_creation_in_progress_page
    expect(page).to have_content('Your account is not ready yet')
  end

  def when_i_visit_the_provider_page
    visit provider_interface_path
  end

  def then_i_should_be_on_the_applications_page
    expect(page).to have_current_path(provider_interface_applications_path)
  end

  def and_my_dfe_sign_in_uid_has_been_stored
    expect(pre_approved_provider_user.reload.dfe_sign_in_uid).to eq('NEW_UID')
  end
end

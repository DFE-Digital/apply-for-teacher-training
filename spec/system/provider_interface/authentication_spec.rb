require 'rails_helper'

RSpec.describe 'A provider authenticates via DfE Sign-in' do
  include DfESignInHelpers

  let(:provider_user) { create(:provider_user, email_address: 'provider@example.com', dfe_sign_in_uid: 'DFE_SIGN_IN_UID', first_name: 'Michael') }

  scenario 'signing in successfully' do
    given_i_am_registered_as_a_provider_user
    and_i_have_a_dfe_sign_in_account

    when_i_visit_the_provider_interface_applications_path
    then_i_am_redirected_to_the_provider_sign_in_path
    and_i_sign_in_via_dfe_sign_in

    then_i_am_redirected_to_the_provider_interface_applications_path
    and_i_should_see_the_link_to_sign_out
    and_the_timestamp_of_this_sign_in_is_recorded
    and_my_profile_details_are_refreshed

    when_i_signed_in_more_than_2_hours_ago
    then_i_should_see_the_login_page_again
  end

  def given_i_am_registered_as_a_provider_user
    provider_user
  end

  def and_i_have_a_dfe_sign_in_account
    provider_exists_in_dfe_sign_in(
      email_address: 'provider@example.com',
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      first_name: 'Mike',
    )
  end

  def when_i_visit_the_provider_interface_applications_path
    visit provider_interface_applications_path(some_key: 'some_value')
  end

  def then_i_am_redirected_to_the_provider_sign_in_path
    expect(page).to have_current_path(provider_interface_sign_in_path)
  end

  def and_i_sign_in_via_dfe_sign_in
    click_link_or_button 'Sign in using DfE Sign-in'
  end

  def then_i_am_redirected_to_the_provider_interface_applications_path
    expect(page).to have_current_path(provider_interface_applications_path(some_key: 'some_value'))
  end

  def and_i_should_see_the_link_to_sign_out
    expect(page).to have_content('Sign out')
  end

  def when_i_click_sign_out
    click_link_or_button 'Sign out'
  end

  def then_i_should_see_the_login_page_again
    expect(page).to have_button('Sign in using DfE Sign-in')
  end

  def when_i_signed_in_more_than_2_hours_ago
    travel_temporarily_to(2.hours.from_now + 1.second) do
      visit provider_interface_sign_in_path
    end
  end

  def and_the_timestamp_of_this_sign_in_is_recorded
    expect(provider_user.reload.last_signed_in_at).not_to be_nil
  end

  def and_my_profile_details_are_refreshed
    expect(provider_user.reload.first_name).to eq('Mike')
  end
end

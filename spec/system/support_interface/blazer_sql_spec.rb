require 'rails_helper'

RSpec.describe 'Blazer SQL tool' do
  include DfESignInHelpers

  scenario 'logging in to use Blazer' do
    when_i_visit_the_blazer_interface
    then_i_am_redirected_to_login_page
    when_i_sign_in_via_dfe_sign_in
    then_i_see_the_blazer_admin_interface
  end

  def when_i_visit_the_blazer_interface
    visit support_interface_blazer_path
  end

  def then_i_am_redirected_to_login_page
    expect(page).to have_current_path support_interface_sign_in_path
  end

  def when_i_sign_in_via_dfe_sign_in
    sign_in_as_support_user
  end

  def then_i_see_the_blazer_admin_interface
    expect(page).to have_content 'New Query'
    expect(page).to have_current_path "#{support_interface_blazer_path}/" # engine paths end with /
  end
end

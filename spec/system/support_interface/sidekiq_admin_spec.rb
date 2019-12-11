require 'rails_helper'

RSpec.feature 'Sidekiq Admin' do
  include DfESignInHelpers

  scenario 'View the Sidekiq Admin interface' do
    when_i_visit_the_sidekiq_interface
    then_i_should_be_redirected_to_login_page

    when_i_sign_in_via_dfe_sign_in
    then_i_visit_the_sidekiq_interface

    then_i_should_see_the_sidekiq_admin_interface
  end

  def when_i_visit_the_sidekiq_interface
    visit support_interface_sidekiq_path
  end

  def then_i_should_be_redirected_to_login_page
    expect(page).to have_current_path support_interface_sign_in_path
  end

  def when_i_sign_in_via_dfe_sign_in
    sign_in_as_support_user
  end

  def then_i_visit_the_sidekiq_interface
    visit support_interface_sidekiq_path
  end

  def then_i_should_see_the_sidekiq_admin_interface
    expect(page).to have_content 'Sidekiq'
    expect(page).to have_current_path support_interface_sidekiq_path
  end
end

require 'rails_helper'

RSpec.feature 'Signing out' do
  scenario 'Logged in candidate signs out' do
    given_i_am_signed_in
    and_i_visit_the_site
    when_i_click_the_sign_out_button
    then_i_should_be_signed_out
  end

  def given_i_am_signed_in
    candidate = create(:candidate)
    login_as(candidate)
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_the_sign_out_button
    click_link 'Sign out'
  end

  def then_i_should_be_signed_out
    expect(page).not_to have_selector :link_or_button, 'Sign out'
    expect(page).to have_current_path(candidate_interface_start_path)
  end
end

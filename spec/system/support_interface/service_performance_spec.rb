require 'rails_helper'

RSpec.feature 'Service performance' do
  include DfESignInHelpers

  scenario 'View service statistics' do
    given_i_am_a_support_user
    and_there_are_candidates_in_the_system

    when_i_visit_the_service_performance_page
    then_i_should_see_the_total_count_of_candidates
  end

  def given_i_am_a_support_user
    support_user_exists_in_dfe_sign_in(email_address: 'user@apply-support.com', dfe_sign_in_uid: 'abc')
    visit support_interface_path
    click_button 'Sign in using DfE Sign-in'
  end

  def and_there_are_candidates_in_the_system
    create_list(:candidate, 2)
  end

  def when_i_visit_the_service_performance_page
    visit support_interface_performance_path
  end

  def then_i_should_see_the_total_count_of_candidates
    within '#total-sign-ups' do
      expect(page).to have_content '2'
    end
  end
end

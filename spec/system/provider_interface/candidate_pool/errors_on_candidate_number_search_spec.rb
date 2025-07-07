require 'rails_helper'

RSpec.describe 'Providers views candidate pool list' do
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  scenario 'Provider enters invalid data into candidate number search' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_is_opted_in_to_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_find_candidates_page
    and_i_search_with('')
    then_i_see_the_error('Enter a candidate number to search')

    when_i_search_with('10.3')
    then_i_see_the_error('Candidate number can only contain numbers 0 to 9')

    when_i_search_with('abc')
    then_i_see_the_error('Candidate number can only contain numbers 0 to 9')
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end

  def and_provider_is_opted_in_to_candidate_pool
    create(:candidate_pool_provider_opt_in, provider: current_provider)
  end

  def when_i_visit_the_find_candidates_page
    visit provider_interface_candidate_pool_root_path
  end

  def and_i_search_with(search_term)
    fill_in 'Search by candidate number', with: search_term
    click_on 'Search'
  end
  alias_method :when_i_search_with, :and_i_search_with

  def then_i_see_the_error(error)
    expect(page.title).to include 'Error:'
    expect(page).to have_content 'There is a problem'
    expect(page).to have_content(error).twice
  end
end

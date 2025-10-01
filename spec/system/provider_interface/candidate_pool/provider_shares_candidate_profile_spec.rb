require 'rails_helper'

RSpec.describe 'Provider shares candiate profile' do
  include CourseOptionHelpers
  include DfESignInHelpers

  let(:current_provider) { create(:provider) }

  scenario 'View a candidate', :js do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_provider_user_exists
    and_there_are_candidates_for_candidate_pool
    and_i_sign_in_to_the_provider_interface

    when_i_visit_the_find_candidates_page
    and_i_click_on_a_candidate
    then_i_am_redirected_to_view_that_candidate

    when_i_click('Share this candidate’s profile')
    then_i_am_redirected_to_the_share_page
    when_i_click('Copy link to clipboard')
    then_i_can_see_success_message
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_provider_user_exists
    provider_user_exists_in_apply_database(provider_code: current_provider.code)
  end

  def and_there_are_candidates_for_candidate_pool
    @rejected_candidate = create(:candidate)
    create(:candidate_preference, candidate: @rejected_candidate)
    @rejected_candidate_form = create(
      :application_form,
      :completed,
      first_name: 'Rejected',
      last_name: 'Candidate',
      candidate: @rejected_candidate,
      submitted_at: 1.day.ago,
    )
    create(:candidate_pool_application, application_form: @rejected_candidate_form)
  end

  def when_i_visit_the_find_candidates_page
    visit provider_interface_candidate_pool_root_path
  end

  def and_i_click_on_a_candidate
    click_on @rejected_candidate.redacted_full_name_current_cycle
  end

  def then_i_am_redirected_to_view_that_candidate
    expect(page).to have_current_path(provider_interface_candidate_pool_candidate_path(@rejected_candidate), ignore_query: true)
  end

  def when_i_click(button)
    click_link_or_button button
  end

  def then_i_am_redirected_to_the_share_page
    expect(page).to have_current_path(provider_interface_candidate_pool_candidate_shares_path(@rejected_candidate), ignore_query: true)

    host = Capybara.current_session.server.host
    port = Capybara.current_session.server.port
    expect(page).to have_content(
      "http://#{host}:#{port}#{provider_interface_candidate_pool_candidate_path(@rejected_candidate)}",
    )
  end

  def then_i_can_see_success_message
    expect(page).to have_content('Link copied to clipboard')
  end
end

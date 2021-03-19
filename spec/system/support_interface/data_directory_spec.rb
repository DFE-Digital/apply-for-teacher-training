require 'rails_helper'

RSpec.feature 'Data export', sidekiq: false do
  include DfESignInHelpers

  scenario 'Support user navigates the data directory' do
    given_i_am_a_support_user
    and_there_are_provider_users_in_the_system

    when_i_visit_the_data_directory_page
    and_i_click_on_view_export_information
    then_i_see_the_export_documentation

    when_i_click_the_generate_new_export_button
    and_i_see_that_the_export_has_started
    when_the_sidekiq_worker_has_finished
    and_i_refresh_the_page
    and_i_click_the_download_link
    then_the_export_is_downloaded

    when_i_go_back_to_the_export_page
    and_i_click_on_the_export_history
    then_i_see_a_record_of_my_completed_export
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_provider_users_in_the_system
    @provider1 = create(:provider)
    @provider2 = create(:provider)
    @provider_user_with_permissions = create(
      :provider_user,
      :with_view_safeguarding_information,
      :with_manage_organisations,
      :with_manage_users,
      :with_make_decisions,
      :with_view_diversity_information,
      providers: [@provider1],
      last_signed_in_at: 5.days.ago,
    )
    @provider_user2 = create(:provider_user, providers: [@provider2], last_signed_in_at: 5.days.ago)
    @provider_user3 = create(:provider_user, providers: [@provider1, @provider2], last_signed_in_at: 3.days.ago)
    create(:provider_user, providers: [@provider1])
  end

  def when_i_visit_the_data_directory_page
    visit support_interface_data_directory_path
  end

  def and_i_click_on_view_export_information
    first(:link, 'View export information').click
  end

  def then_i_see_the_export_documentation
    expect(page).to have_content 'Documentation'
    expect(page).to have_content 'name'
    expect(page).to have_content 'string'
  end

  def when_i_click_the_generate_new_export_button
    Sidekiq::Worker.clear_all
    click_button 'Generate new export'
  end

  def and_i_see_that_the_export_has_started
    expect(page).to have_content 'This export is being generated'
  end

  def when_the_sidekiq_worker_has_finished
    Sidekiq::Worker.drain_all
  end

  def and_i_refresh_the_page
    @url = page.current_url
    visit @url
  end

  def and_i_click_the_download_link
    click_link 'Download export'
  end

  def then_the_export_is_downloaded
    expect(page).to have_content 'name,email_address,provider'
  end

  def when_i_go_back_to_the_export_page
    visit @url
    click_link 'Active provider user permissions'
  end

  def and_i_click_on_the_export_history
    click_link 'View history'
  end

  def then_i_see_a_record_of_my_completed_export
    expect(page).to have_content 'Active provider user permissions download history'
    expect(page).to have_content 'completed'
  end
end

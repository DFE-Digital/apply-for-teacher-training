require 'rails_helper'

RSpec.feature 'Data export', sidekiq: false do
  include DfESignInHelpers

  scenario 'Support user can download CSVs' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system

    when_i_visit_the_data_exports_page
    and_i_click_the_generate_report_link
    then_i_see_that_the_export_has_started

    when_the_sidekiq_worker_has_finished
    and_i_refresh_the_page
    and_i_click_the_download_link
    then_the_export_is_downloaded
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_applications_in_the_system
    create(:application_choice, :awaiting_provider_decision)
  end

  def when_i_visit_the_data_exports_page
    visit support_interface_data_exports_path
    click_link 'New export'
  end

  def and_i_click_the_generate_report_link
    Sidekiq::Worker.clear_all
    click_button 'Generate Candidate journey tracking export'
  end

  def then_i_see_that_the_export_has_started
    expect(page).to have_content 'This export is being generated'
  end

  def when_the_sidekiq_worker_has_finished
    Sidekiq::Worker.drain_all
  end

  def and_i_refresh_the_page
    visit page.current_url
  end

  def and_i_click_the_download_link
    click_link 'Download export'
  end

  def then_the_export_is_downloaded
    expect(page).to have_content 'application_choice_id,choice_status,recruitment_cycle_year'
  end
end

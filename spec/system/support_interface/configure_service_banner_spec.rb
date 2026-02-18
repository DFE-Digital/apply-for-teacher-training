require 'rails_helper'

RSpec.describe 'Configure service banner' do
  include DfESignInHelpers

  scenario 'Create, configure, publish and unpublish a service banner' do
    given_i_am_a_support_user

    when_i_visit_the_settings_page
    and_i_click_on_service_banners
    then_i_see_configuration_components_for_each_interface

    when_i_click_to_configure_the_support_console_service_banner
    then_i_see_the_show_service_banner_page

    click_link_or_button 'Continue'
    then_i_see_validation_error_for_not_selecting_a_response

    when_i_select_yes
    then_i_see_the_form_for_configuring_custom_banner_content

    click_link_or_button 'Preview banner'
    then_i_see_validation_error_for_not_supplying_header_text

    when_i_exceed_the_character_limit_for_banner_content
    click_link_or_button 'Preview banner'
    then_i_also_see_validation_error_for_exceeding_character_limit

    when_i_enter_valid_header_and_body_content
    click_link_or_button 'Preview banner'
    then_i_see_a_banner_preview

    click_link_or_button 'Publish banner'
    then_i_see_a_success_message
    and_the_component_reflects_banner_state_and_includes_a_preview_of_the_banner_text

    click_link_or_button 'Candidates'
    then_i_see_the_published_banner

    when_i_visit_the_settings_page
    and_i_click_on_service_banners
    and_i_click_to_configure_the_support_console_service_banner
    and_i_choose_no
    then_i_see_the_banner_has_been_disabled
  end

  scenario 'Edit then disable a service banner and view audit history', :with_audited do
    given_i_am_a_support_user
    and_a_service_banner_for_apply_exists_with_activity

    when_i_visit_the_settings_page
    and_i_click_on_service_banners
    then_i_see_an_entry_in_the_apply_banner_configuration_component_history_row

    when_i_click_to_edit_the_banner_content
    and_i_make_changes
    click_link_or_button 'Preview banner'
    click_link_or_button 'Publish banner'
    then_i_see_an_updated_preview_in_the_component

    when_i_click_to_configure_the_apply_service_banner
    and_i_choose_no
    then_i_see_a_success_message_saying_the_banner_is_disabled
    and_new_audit_entries_are_in_the_history_row

    when_i_click_the_latest_audit_link
    then_i_see_the_audit_history_for_this_banner
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
    @support_user = SupportUser.find_by(email_address: 'user@apply-support.com')
  end

  def and_a_service_banner_for_apply_exists_with_activity
    @banner = create(:service_banner, :published) # Apply by default

    Audited.audit_class.as_user(@support_user) do
      @banner.update!(header: 'The service will be unavailable from 6pm this evening until midnight')
    end
  end

  def when_i_visit_the_settings_page
    visit support_interface_settings_path
  end

  def and_i_click_on_service_banners
    click_link_or_button 'Service banners'
  end

  def then_i_see_configuration_components_for_each_interface
    expect(page).to have_content('Manage service banner')
    expect(page).to have_content('Apply service banner')
    expect(page).to have_content('Support Console service banner')
  end

  def when_i_click_to_configure_the_support_console_service_banner
    within '.app-summary-card', text: 'Support Console service banner' do
      within '.govuk-summary-list__row', text: 'Show service banner' do
        click_link_or_button 'Change'
      end
    end
  end
  alias_method :and_i_click_to_configure_the_support_console_service_banner, :when_i_click_to_configure_the_support_console_service_banner

  def when_i_click_to_configure_the_apply_service_banner
    within '.app-summary-card', text: 'Apply service banner' do
      within '.govuk-summary-list__row', text: 'Show service banner' do
        click_link_or_button 'Change'
      end
    end
  end

  def then_i_see_the_show_service_banner_page
    expect(page).to have_content 'Show Support Console service banner'
  end

  def when_i_select_yes
    choose 'Yes'
    click_link_or_button 'Continue'
  end

  def then_i_see_the_form_for_configuring_custom_banner_content
    expect(page).to have_content 'Configure Support Console service banner'
    expect(page).to have_content 'Header'
    expect(page).to have_content 'Banner content (optional)'
  end

  def then_i_see_validation_error_for_not_selecting_a_response
    expect(page).to have_content 'Select a response'
  end

  def then_i_see_validation_error_for_not_supplying_header_text
    expect(page).to have_content 'You must include a banner header'
  end

  def when_i_exceed_the_character_limit_for_banner_content
    fill_in 'Banner content', with: 'Hello' * 100
  end

  def then_i_also_see_validation_error_for_exceeding_character_limit
    expect(page).to have_content 'You must include a banner header'
    expect(page).to have_content 'Body must be 400 characters or fewer'
  end

  def when_i_enter_valid_header_and_body_content
    fill_in 'Header', with: 'The service will be offline from 6pm to 9pm this evening'
    fill_in 'Banner content', with: 'You may lose your work if it is unsaved at 6pm'
  end

  def then_i_see_a_banner_preview
    expect(page).to have_content('Preview Support Console service banner')
    expect(page).to have_content('The service will be offline from 6pm to 9pm this evening')
    expect(page).to have_content('You may lose your work if it is unsaved at 6pm')
  end

  def then_i_see_a_success_message
    expect(page).to have_content('Support Console service banner enabled')
  end

  def and_the_component_reflects_banner_state_and_includes_a_preview_of_the_banner_text
    within '.app-summary-card', text: 'Support Console service banner' do
      within '.govuk-summary-list__row', text: 'Show service banner' do
        expect(page).to have_content('Yes')
      end
      within '.govuk-summary-list__row', text: 'Banner content' do
        expect(page).to have_content('The service will be offline from 6pm to 9pm this evening')
        expect(page).to have_content('You may lose your work if it is unsaved at 6pm')
      end
    end
  end

  def then_i_see_the_published_banner
    expect(page).to have_content('The service will be offline from 6pm to 9pm this evening')
    expect(page).to have_content('You may lose your work if it is unsaved at 6pm')
  end

  def and_i_choose_no
    choose 'No'
    click_link_or_button 'Continue'
  end

  def then_i_see_the_banner_has_been_disabled
    expect(page).to have_content('Support Console service banner disabled')

    click_link_or_button 'Candidates'
    expect(page).to have_no_content('Important')
    expect(page).to have_no_content('The service will be offline from 6pm to 9pm this evening')
    expect(page).to have_no_content('You may lose your work if it is unsaved at 6pm')
  end

  def then_i_see_an_entry_in_the_apply_banner_configuration_component_history_row
    within '.app-summary-card', text: 'Apply service banner' do
      within '.govuk-summary-list__row', text: 'History' do
        expect(page).to have_content('Banner enabled by user@apply-support.com')
      end
    end
  end

  def when_i_click_to_edit_the_banner_content
    within '.app-summary-card', text: 'Apply service banner' do
      within '.govuk-summary-list__row', text: 'Banner content' do
        click_link_or_button 'Change'
      end
    end
  end

  def and_i_make_changes
    fill_in 'Header', with: 'Changed header'
    fill_in 'Banner content', with: 'Changed body content'
  end

  def then_i_see_an_updated_preview_in_the_component
    within '.app-summary-card', text: 'Apply service banner' do
      within '.govuk-summary-list__row', text: 'Show service banner' do
        expect(page).to have_content('Yes')
      end
      within '.govuk-summary-list__row', text: 'Banner content' do
        expect(page).to have_content('Changed header')
        expect(page).to have_content('Changed body content')
      end
    end
  end

  def and_new_audit_entries_are_in_the_history_row
    within '.app-summary-card', text: 'Apply service banner' do
      within '.govuk-summary-list__row', text: 'History' do
        expect(page).to have_content('Banner disabled by user@apply-support.com', count: 1)
        expect(page).to have_content('Banner enabled by user@apply-support.com', count: 2)
      end
    end
  end

  def then_i_see_the_edited_banner_is_live
    expect(page).to have_content('Changed header')
    expect(page).to have_content('Changed body content')
  end

  def when_i_click_the_latest_audit_link
    within '.app-summary-card', text: 'Apply service banner' do
      within '.govuk-summary-list__row', text: 'History' do
        first(:link_or_button, 'Banner enabled by user@apply-support.com').click
      end
    end
  end

  def then_i_see_the_audit_history_for_this_banner
    expect(page).to have_content('Apply banner history')
    expect(page).to have_content('Banner disabled by user@apply-support.com', count: 1)
    expect(page).to have_content('Banner enabled by user@apply-support.com', count: 2)

    expect(page).to have_content('Changed header')
    expect(page).to have_content('Changed body content')
  end

  def then_i_see_a_success_message_saying_the_banner_is_disabled
    expect(page).to have_content('Apply service banner disabled')
  end
end

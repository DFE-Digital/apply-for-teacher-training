require 'rails_helper'

RSpec.describe 'Generating new data exports', :with_audited do
  include DfESignInHelpers

  scenario 'When the export type has not been deprecated' do
    given_i_am_signed_in_as_a_support_user
    and_i_go_to_the_data_export_page
    and_i_click_on_an_active_export_type
    then_i_see_the_green_button

    and_i_can_enqueue_an_export
  end

  scenario 'When the export type has been deprecated' do
    given_i_am_signed_in_as_a_support_user
    and_i_go_to_the_data_export_page
    and_i_click_on_a_deprecated_export_type
    then_i_do_not_see_the_green_button
  end

private

  def and_i_go_to_the_data_export_page
    click_on 'Performance'
    click_on 'Data directory'
  end

  def and_i_click_on_an_active_export_type
    @active_export_type ||= DataExport.active_export_types.keys.sample
    name = DataExport::EXPORT_TYPES.dig(@active_export_type, :name)

    within('.govuk-main-wrapper') do
      click_on name
    end
  end

  def then_i_see_the_green_button
    expect(page).to have_button('Generate new export')
    expect(page).to have_no_text('This report is no longer in use.')
  end

  def and_i_can_enqueue_an_export
    allow(DataExporter).to receive(:perform_async)
    click_on 'Generate new export'

    expect(DataExporter).to have_received(:perform_async)
    expect(page).to have_text 'This export is being generated. Refresh the page to see if it completed.'
  end

  def then_i_do_not_see_the_green_button
    expect(page).to have_no_button('Generate new export')
    expect(page).to have_text('This report is no longer in use.')
  end

  def and_i_see_a_warning_message
    expect(page).to have_text 'This export type has been deprecated and cannot be generated'
  end

  def and_i_click_on_a_deprecated_export_type
    deprecated_export_type = DataExport.deprecated_export_types.values.map { |et| et[:name] }.sample

    within('.govuk-main-wrapper') do
      click_on deprecated_export_type
    end
  end
end

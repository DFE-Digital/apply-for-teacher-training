require 'rails_helper'

RSpec.feature 'Data set documentation' do
  include DfESignInHelpers

  scenario 'Support user visits the data set documentation' do
    given_i_am_a_support_user
    and_i_visit_the_new_data_exports_page
    and_i_click_on_the_tad_export_documentation
    then_i_see_the_data_set_documentation
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_i_visit_the_new_data_exports_page
    visit new_support_interface_data_export_path
  end

  def and_i_click_on_the_tad_export_documentation
    click_link 'View documentation for TAD applications'
  end

  def then_i_see_the_data_set_documentation
    expect(page).to have_content 'extract_date'
  end
end

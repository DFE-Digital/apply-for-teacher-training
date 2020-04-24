require 'rails_helper'

RSpec.feature 'Validation errors' do
  include DfESignInHelpers

  scenario 'Review validation errors' do
    given_i_am_a_support_user
    and_there_are_some_validation_errors

    when_i_navigate_to_the_validation_errors_page
    then_i_should_see_a_list_of_error_groups

    when_i_click_on_a_group
    then_i_should_see_a_list_of_individual_errors
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_some_validation_errors
    @validation_error = create(
      :validation_error,
      created_at: Time.zone.local(2020, 4, 24, 12, 35, 42),
    )
  end

  def when_i_navigate_to_the_validation_errors_page
    visit support_interface_path
    click_link 'Performance'
    click_link 'Validation errors'
  end

  def then_i_should_see_a_list_of_error_groups
    expect(page).to have_content(@validation_error.form_object)
    expect(page).to have_content('(1)')
  end

  def when_i_click_on_a_group
    click_on(@validation_error.form_object)
  end

  def then_i_should_see_a_list_of_individual_errors
    expect(page).to have_current_path(support_interface_validation_error_path(@validation_error.form_object))
    expect(page).to have_content(@validation_error.request_path)
    expect(page).to have_content(@validation_error.created_at)
  end
end

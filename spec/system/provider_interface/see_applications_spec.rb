require 'rails_helper'

RSpec.describe 'See applications' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'Provider visits application page' do
    given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    and_my_organisation_has_applications

    and_i_sign_in_to_the_provider_interface
    then_i_see_the_email_address_not_recognised_page

    when_my_apply_account_has_been_created
    and_i_sign_in_to_the_provider_interface
    then_i_see_the_applications_from_my_organisation
    and_i_see_the_applications_menu_item_highlighted

    when_i_click_on_an_application
    then_i_am_on_the_application_view_page
  end

  def when_my_apply_account_has_been_created
    provider_user_exists_in_apply_database(provider_code: 'ABC')
  end

  def given_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def then_i_see_the_email_address_not_recognised_page
    expect(page).to have_content('Your email address is not recognised')
  end

  def and_my_organisation_has_applications
    course_option = course_option_for_provider_code(provider_code: 'ABC')

    @my_provider_choice1  = create(:application_choice, :awaiting_provider_decision,
                                   :with_completed_application_form,
                                   status: 'awaiting_provider_decision',
                                   course_option:)
    @my_provider_choice2  = create(:application_choice, :awaiting_provider_decision,
                                   status: 'awaiting_provider_decision',
                                   course_option:)
  end

  def then_i_see_the_applications_from_my_organisation
    expect(page).to have_title 'Applications (2)'
    expect(page).to have_content 'Applications (2)'
    expect(page).to have_content @my_provider_choice1.application_form.full_name
    expect(page).to have_content @my_provider_choice2.application_form.full_name
  end

  def and_i_see_the_applications_menu_item_highlighted
    link = page.find_link('Applications', class: 'govuk-service-navigation__link')
    expect(link['aria-current']).to eq('page')
  end

  def when_i_click_on_an_application
    click_link_or_button @my_provider_choice1.application_form.full_name
  end

  def then_i_am_on_the_application_view_page
    expect(page).to have_content @my_provider_choice1.id

    expect(page).to have_content @my_provider_choice1.application_form.full_name
  end
end

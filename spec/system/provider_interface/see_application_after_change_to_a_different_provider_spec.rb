require 'rails_helper'

RSpec.feature 'An application was changed to another provider' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'And the old provider can only see part of their application' do
    given_an_application_which_has_changed_provider
    and_i_am_a_provider_user_authenticated_with_dfe_sign_in

    when_i_belong_to_the_original_provider
    and_i_visit_the_provider_interface
    and_i_sign_in_to_the_provider_interface
    then_i_can_see_the_application

    and_i_visit_the_provider_interface
    when_i_click_on_the_individual_application
    then_i_can_see_only_the_application_and_offer_tabs

    when_i_click_on_the_offer_tab
    then_i_can_see_only_the_application_and_offer_tabs
  end

  def given_an_application_which_has_changed_provider
    @old_provider = create(:provider, code: 'XXX')
    @new_provider = create(:provider, code: 'YYY')
    old_course = create(:course, provider: @old_provider)
    new_course = create(:course, provider: @new_provider)
    old_course_option = create(:course_option, course: old_course)
    new_course_option = create(:course_option, course: new_course)

    @application_choice = create(
      :application_choice,
      :offered,
      course_option: old_course_option,
      current_course_option: new_course_option,
    )
  end

  def and_i_am_a_provider_user_authenticated_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end

  def when_i_belong_to_the_original_provider
    @provider_user = provider_user_exists_in_apply_database
    @provider_user.providers << @old_provider
  end

  def and_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def then_i_can_see_the_application
    expect(page).to have_content @application_choice.application_form.full_name
  end

  def when_i_click_on_the_individual_application
    click_link @application_choice.application_form.full_name
  end

  def then_i_can_see_only_the_application_and_offer_tabs
    expect(navigation_tabs).to eq(%w[Application Offer])
  end

  def when_i_click_on_the_offer_tab
    click_link 'Offer'
  end

  def navigation_tabs
    page.first('.app-tab-navigation').text.split
  end
end

require 'rails_helper'

RSpec.describe 'Provider confirms a deferred offer' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  scenario 'Provider views the check page for a deferred offer' do
    given_i_am_a_provider_user_with_dfe_sign_in
    permit_make_decisions!
    and_i_sign_in_to_the_provider_interface

    and_applications_with_status_offer_deferred_exist

    when_i_visit_a_application_with_status_offer_deferred_from_previous_cycle
    and_i_click_confirm_deferred_offer

    # Check
    then_i_can_see_the_details_of_the_deferred_offer
    click_on "Continue"

    # Conditions
    then_i_can_see_the_conditions_page
    and_i_choose_conditions_met
    click_on "Confirm deferred offer"

    then_i_see_the_success_message
    within ".app-tab-navigation" do
      click_on "Offer"
    end
    within '#offer-conditions-list' do
      expect(page).to have_content('You must obtain a degree met')
    end
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in

    @provider = create(:provider, code: 'ZZZ', name: 'Provider Deferring')

    provider_user_exists_in_apply_database(provider_code: 'ZZZ')
  end

  def and_applications_with_status_offer_deferred_exist
    @course = create(:course, :open, :previous_year, provider: @provider, name: 'Primary', code: 'PR1')
    @site = create(:site,
                   provider: @provider,
                   name: 'Main site',
                   code: 'MS',
                   address_line1: '123 Fake Street',
                   address_line2: nil, address_line3: nil, address_line4: nil,
                   postcode: 'E1 1AA')
    @course_option = create(:course_option,
                            course: @course,
                            study_mode: 'part_time',
                            site: @site)


    course_current_cycle = create(:course, :open, provider: @provider, name: 'Primary', code: 'PR1')
    # site_current_cycle = create(:site,
    #                provider: @provider,
    #                name: 'Main site',
    #                             code: 'MS',
    #                address_line1: '123 Fake Street',
    #                address_line2: nil, address_line3: nil, address_line4: nil,
    #                postcode: 'E1 1AA')
    _course_option_current_cycle = create(:course_option,
                            course: course_current_cycle,
                            study_mode: 'part_time',
                            site: @site)

    @deferred_application_choice = create(
      :application_choice,
      :previous_year,
      :offer_deferred,
      course_option: @course_option,
      form_options: {
        first_name: 'John',
        last_name: 'Doe',
      },
      offer: build(:offer, conditions: [build(:text_condition, description: 'You must obtain a degree', status: :pending)]),
    )
  end

  def when_i_visit_a_application_with_status_offer_deferred_from_previous_cycle
    visit provider_interface_application_choice_path(@deferred_application_choice)
    expect(page).to have_current_path(provider_interface_application_choice_path(@deferred_application_choice))
  end

  def and_i_click_confirm_deferred_offer
    # click_on 'Confirm deferred offer'
    visit provider_interface_deferred_offer_check_path(@deferred_application_choice)
  end

  def then_i_can_see_the_details_of_the_deferred_offer
    expect(page).to have_current_path provider_interface_deferred_offer_check_path(@deferred_application_choice)
    expect(page).to have_css('h1', text: 'John Doe')
    expect(page).to have_css('h1', text: 'Check offered course details')

    within '#check_provider' do
      expect(page).to have_content('Provider')
      expect(page).to have_content('Provider Deferring (ZZZ)')
      expect(page).to have_no_link('Change')
    end

    within '#check_course' do
      expect(page).to have_content('Course')
      expect(page).to have_content('Primary (PR1)')
      # expect(page).to have_link('Change course', href: '#')
    end

    within '#check_study_mode' do
      expect(page).to have_content('Full time or part time')
      expect(page).to have_content('Part time')
      # expect(page).to have_link('Change full time or part time', href: '#')
    end

    within '#check_location' do
      expect(page).to have_content('Location')
      expect(page).to have_content('Main site, 123 Fake Street, E1 1AA')
      # expect(page).to have_link('Change location', href: '#')
    end

    expect(page).to have_css('h2', text: 'Conditions of offer')

    within '#check_conditions' do
      expect(page).to have_content('You must obtain a degree')
      expect(page).to have_content('Pending')
      # expect(page).to have_no_link('Change')
    end
  end

  def then_i_can_see_the_conditions_page
    expect(page).to have_current_path(provider_interface_deferred_offer_conditions_path(@deferred_application_choice))

    expect(page).to have_css('h1', text: 'John Doe')
    expect(page).to have_css('h1', text: 'Confirm status of conditions')

    expect(page).to have_css('fieldset > legend', text: 'Has the candidate met all of the conditions?')
  end

  def and_i_choose_conditions_met
    choose 'Yes, all conditions are met'
  end

  def then_i_see_the_success_message
    expect(page).to have_content('Deferred offer successfully confirmed for current cycle')
  end
end

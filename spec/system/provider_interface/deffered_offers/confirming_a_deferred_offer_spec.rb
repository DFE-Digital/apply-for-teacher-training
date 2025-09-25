require 'rails_helper'

RSpec.describe 'Provider confirms a deferred offer' do
  include DfESignInHelpers

  scenario 'Provider wants to deferred an offer without any changes - the course, study mode and location are all available in the current cycle' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    and_applications_with_status_offer_deferred_exist
    and_the_deferred_course_location_and_study_mode_is_available_in_current_cycle

    when_i_visit_a_application_with_status_offer_deferred_from_previous_cycle
    and_i_click_confirm_deferred_offer

    then_i_can_see_the_details_of_the_deferred_offer

    click_on 'Continue'

    # Conditions
    then_i_can_see_the_conditions_page
    and_i_choose_conditions_met
    click_on 'Confirm deferred offer'
  end

  scenario 'Provider wants to deferred an offer changing the location - the course and study mode are available in the current cycle, but the original location is not' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    and_applications_with_status_offer_deferred_exist
    and_the_deferred_course_and_study_mode_is_available_in_current_cycle

    when_i_visit_a_application_with_status_offer_deferred_from_previous_cycle
    and_i_click_confirm_deferred_offer

    and_i_select_a_different_location

    then_i_can_see_the_updated_location_on_the_check_page
    click_on 'Continue'

    # Conditions
    then_i_can_see_the_conditions_page
    and_i_choose_conditions_met
    click_on 'Confirm deferred offer'
  end

  scenario 'Provider wants to deferred an offer changing the study mode - the course and location are available in the current cycle, but the original study mode is not' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    and_applications_with_status_offer_deferred_exist
    and_the_deferred_course_and_location_is_available_in_current_cycle

    when_i_visit_a_application_with_status_offer_deferred_from_previous_cycle
    and_i_click_confirm_deferred_offer

    and_i_select_a_different_study_mode

    then_i_can_see_the_updated_study_mode_on_the_check_page
    click_on 'Continue'

    # Conditions
    then_i_can_see_the_conditions_page
    and_i_choose_conditions_met
    click_on 'Confirm deferred offer'
  end

  scenario 'Provider wants to deferred an offer changing the course - the original course, study mode and location are available in the current cycle, but the provider wants to change to a different course' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    and_applications_with_status_offer_deferred_exist
    and_the_deferred_course_location_and_study_mode_is_available_in_current_cycle
    and_other_courses_are_available_in_current_cycle

    when_i_visit_a_application_with_status_offer_deferred_from_previous_cycle
    and_i_click_confirm_deferred_offer

    then_i_can_see_the_details_of_the_deferred_offer

    when_i_click_change_course
    and_i_select_a_different_course
    and_i_select_a_different_location
    and_i_select_a_different_study_mode

    then_i_can_see_the_updated_course_on_the_check_page
    then_i_can_see_the_updated_location_on_the_check_page
    then_i_can_see_the_updated_study_mode_on_the_check_page

    click_on 'Continue'

    # Conditions
    then_i_can_see_the_conditions_page
    and_i_choose_conditions_met
    click_on 'Confirm deferred offer'
  end

  scenario 'Provider wants to deferred an offer - the original course, study mode and location are not available in the current cycle' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_sign_in_to_the_provider_interface

    and_applications_with_status_offer_deferred_exist
    and_the_deferred_course_is_not_available_in_current_cycle
    and_other_courses_are_available_in_current_cycle

    when_i_visit_a_application_with_status_offer_deferred_from_previous_cycle
    and_i_click_confirm_deferred_offer

    and_i_select_a_different_course
    and_i_select_a_different_location
    and_i_select_a_different_study_mode

    then_i_can_see_the_updated_course_on_the_check_page
    then_i_can_see_the_updated_location_on_the_check_page
    then_i_can_see_the_updated_study_mode_on_the_check_page

    click_on 'Continue'

    # Conditions
    then_i_can_see_the_conditions_page
    and_i_choose_conditions_met
    click_on 'Confirm deferred offer'
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in

    @provider = create(:provider, code: 'ZZZ', name: 'Provider Deferring')

    provider_user_exists_in_apply_database(provider_code: 'ZZZ')
  end

  def and_applications_with_status_offer_deferred_exist
    @deferred_course_in_previous_cycle = create(:course, :previous_year, provider: @provider, name: 'Primary', code: 'PR1')
    @site = create(:site,
                   provider: @provider,
                   name: 'Main site',
                   address_line1: '123 Fake Street',
                   address_line2: nil, address_line3: nil, address_line4: nil,
                   postcode: 'E1 1AA')
    @deferred_course_option_in_previous_cycle = create(:course_option,
                                                       course: @deferred_course_in_previous_cycle,
                                                       study_mode: 'part_time',
                                                       site: @site)

    @deferred_application_choice = create(
      :application_choice,
      :previous_year,
      :offer_deferred,
      course_option: @deferred_course_option_in_previous_cycle,
      current_course_option: @deferred_course_option_in_previous_cycle,
      form_options: {
        first_name: 'John',
        last_name: 'Doe',
      },
      offer: build(:offer, conditions: [build(:text_condition, description: 'You must obtain a degree', status: :pending)]),
    )
  end

  def and_the_deferred_course_location_and_study_mode_is_available_in_current_cycle
    @deferred_course_in_current_cycle = create(:course, :open, provider: @provider, name: 'Primary', code: 'PR1')
    @deferred_course_option_in_current_cycle = create(:course_option,
                                                      course: @deferred_course_in_current_cycle,
                                                      study_mode: 'part_time',
                                                      site: @site)
  end

  def and_the_deferred_course_and_study_mode_is_available_in_current_cycle
    @other_site = create(:site,
                         provider: @provider,
                         name: 'Other site',
                         address_line1: '567 Really Fake Lane',
                         address_line2: nil, address_line3: nil, address_line4: nil,
                         postcode: 'F2 2BB')
    @deferred_course_in_current_cycle = create(:course, :open, provider: @provider, name: 'Primary', code: 'PR1')
    @deferred_course_option_in_current_cycle = create(:course_option,
                                                      course: @deferred_course_in_current_cycle,
                                                      study_mode: 'part_time',
                                                      site: @other_site)
  end

  def and_the_deferred_course_and_location_is_available_in_current_cycle
    @deferred_course_in_current_cycle = create(:course, :open, provider: @provider, name: 'Primary', code: 'PR1')
    @deferred_course_option_in_current_cycle = create(:course_option,
                                                      course: @deferred_course_in_current_cycle,
                                                      study_mode: 'full_time',
                                                      site: @site)
  end

  def and_the_deferred_course_is_not_available_in_current_cycle = nil

  def and_other_courses_are_available_in_current_cycle
    @other_course_in_current_cycle = create(:course, :open, provider: @provider, name: 'Secondary', code: 'SC1')
    @other_site = create(:site,
                         provider: @provider,
                         name: 'Other site',
                         address_line1: '567 Really Fake Lane',
                         address_line2: nil, address_line3: nil, address_line4: nil,
                         postcode: 'F2 2BB')
    @course_option = create(:course_option, course: @other_course_in_current_cycle, study_mode: 'full_time', site: @other_site)
  end

  def when_i_visit_a_application_with_status_offer_deferred_from_previous_cycle
    visit provider_interface_application_choice_path(@deferred_application_choice)
    expect(page).to have_current_path(provider_interface_application_choice_path(@deferred_application_choice))
  end

  def and_i_click_confirm_deferred_offer
    # click_on 'Confirm deferred offer'
    visit provider_interface_deferred_offer_root_path(@deferred_application_choice)
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
      expect(page).to have_link('Change course', href: provider_interface_deferred_offer_course_path(@deferred_application_choice))
    end

    within '#check_study_mode' do
      expect(page).to have_content('Full time or part time')
      expect(page).to have_content('Part time')
      expect(page).to have_link('Change full time or part time', href: provider_interface_deferred_offer_study_mode_path(@deferred_application_choice))
    end

    within '#check_location' do
      expect(page).to have_content('Location')
      expect(page).to have_content('Main site, 123 Fake Street, E1 1AA')
      expect(page).to have_link('Change location', href: provider_interface_deferred_offer_location_path(@deferred_application_choice))
    end

    expect(page).to have_css('h2', text: 'Conditions of offer')

    within '#check_conditions' do
      expect(page).to have_content('You must obtain a degree')
      expect(page).to have_content('Pending')
      expect(page).to have_no_link('Change')
    end
  end

  def when_i_click_change_course
    within '#check_course' do
      click_on 'Change course'
    end
  end

  def and_i_select_a_different_course
    choose 'Secondary (SC1)'
    click_on 'Change course'
  end

  def then_i_can_see_the_updated_course_on_the_check_page
    within '#check_course' do
      expect(page).to have_content('Course')
      expect(page).to have_content('Secondary (SC1)')
      expect(page).to have_link('Change course', href: provider_interface_deferred_offer_course_path(@deferred_application_choice))
    end
  end

  def when_i_click_select_full_time_or_part_time
    within '#check_study_mode' do
      click_on 'Select full time or part time'
    end
  end

  def and_i_select_a_different_study_mode
    choose 'Full time'
    click_on 'Change study type'
  end

  def then_i_can_see_the_updated_study_mode_on_the_check_page
    within '#check_study_mode' do
      expect(page).to have_content('Full time or part time')
      expect(page).to have_content('Full time')
      expect(page).to have_link('Change full time or part time', href: provider_interface_deferred_offer_study_mode_path(@deferred_application_choice))
    end
  end

  def when_i_click_select_location
    within '#check_location' do
      click_on 'Select location'
    end
  end

  def and_i_select_a_different_location
    choose 'Other site'
    click_on 'Change location'
  end

  def then_i_can_see_the_updated_location_on_the_check_page
    within '#check_location' do
      expect(page).to have_content('Location')
      expect(page).to have_content('Other site, 567 Really Fake Lane, F2 2BB')
      expect(page).to have_link('Change location', href: provider_interface_deferred_offer_location_path(@deferred_application_choice))
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
end

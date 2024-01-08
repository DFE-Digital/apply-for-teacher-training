require 'rails_helper'

RSpec.feature 'Provider exits journey when changing a course' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:ratifying_provider) { create(:provider) }
  let(:application_form) { build(:application_form, :minimum_info) }
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           application_form:,
           current_course_option: course_option,
           course_option:)
  end
  let(:course) do
    build(:course, :full_time, provider:, accredited_provider: ratifying_provider)
  end
  let(:course_option) { build(:course_option, :full_time, course:) }

  scenario 'Cancelling journey when changing a course choice before point of offer' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_the_provider_has_multiple_courses

    when_i_visit_the_provider_interface
    and_i_click_an_application_choice
    and_i_click_on_change_the_course
    and_i_select_a_different_course
    and_i_click_continue
    then_i_see_a_list_of_locations_to_select_from

    when_i_click_cancel
    and_i_click_on_change_the_location
    then_i_see_a_list_of_locations_to_select_from
  end

  def given_i_am_a_provider_user
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
  end

  def and_i_am_permitted_to_make_decisions_for_my_provider
    permit_make_decisions!
  end

  def and_i_sign_in_to_the_provider_interface
    provider_signs_in_using_dfe_sign_in
  end

  def and_the_provider_has_multiple_courses
    @selected_course = create(:course, :open_on_apply, study_mode: :full_time, provider:, accredited_provider: ratifying_provider)

    create(:course_option, :full_time, course:)
    create(:course_option, :full_time, course: @selected_course)
    create(:course_option, :full_time, course: @selected_course)

    create(
      :provider_relationship_permissions,
      training_provider: provider,
      ratifying_provider:,
      ratifying_provider_can_make_decisions: true,
    )
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_an_application_choice
    click_link_or_button application_choice.application_form.full_name
  end

  def and_i_click_on_change_the_course
    within(all('.govuk-summary-list__row dt').find { |e| e.text == 'Course' }.find(:xpath, '..')) do
      click_link_or_button 'Change'
    end
  end

  def and_i_select_a_different_course
    choose @selected_course.name_and_code
  end

  def and_i_click_continue
    click_link_or_button t('continue')
  end

  def then_i_see_a_list_of_locations_to_select_from
    expect(page).to have_content "Update course - #{application_form.full_name}"
    expect(page).to have_content 'Location'
    expect(page).to have_css('.govuk-radios__item')
  end

  def when_i_click_cancel
    first(:link, 'Cancel').click
  end

  def and_i_click_on_change_the_location
    within(all('.govuk-summary-list__row').find { |e| e.text.include?('Location') }) do
      click_link_or_button 'Change'
    end
  end
end

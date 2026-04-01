require 'rails_helper'

RSpec.describe 'Provider makes an offer with SKE enabled in standard courses' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include OfferStepsHelper

  let(:provider_user) { create(:provider_user, :with_dfe_sign_in) }
  let(:provider) { provider_user.providers.first }
  let(:ratifying_provider) { create(:provider) }
  let(:application_form) { build(:application_form, :minimum_info) }
  let!(:application_choice) do
    create(:application_choice, :awaiting_provider_decision,
           application_form:,
           course_option:)
  end
  let(:course) do
    build(:course, :full_time, provider:, accredited_provider: ratifying_provider)
  end
  let(:course_option) { build(:course_option, course:) }

  before do
    given_the_course_subject_requires_ske
  end

  scenario 'Making an offer for the requested course option' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    given_the_provider_has_multiple_courses
    and_the_other_courses_subject_does_not_require_ske
    given_the_provider_user_can_offer_multiple_provider_courses

    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_awaiting_decision
    and_i_click_on_make_decision
    then_i_see_the_decision_page

    when_i_choose_to_make_an_offer

    then_the_ske_standard_flow_is_loaded
    when_i_dont_select_any_ske_answer
    then_i_see_a_error_message_to_select_if_ske_required

    when_i_select_no_ske_required
    and_i_click_continue
    then_the_conditions_page_is_loaded

    and_i_click_back

    when_i_select_ske_is_required
    and_i_click_continue
    then_the_ske_reason_page_is_loaded

    when_i_dont_give_a_ske_reason
    then_i_see_a_error_message_to_give_a_reason_for_ske

    when_i_add_a_ske_reason
    and_i_click_continue
    then_the_ske_length_page_is_loaded

    when_i_dont_answer_ske_length
    then_i_see_a_error_message_to_give_a_ske_course_length

    when_i_answer_the_ske_length
    and_i_click_continue
    then_the_conditions_page_is_loaded

    when_i_add_further_conditions
    and_i_add_and_remove_another_condition
    and_i_do_not_request_any_specific_references
    and_i_click_continue
    then_the_review_page_is_loaded
    and_i_can_confirm_my_answers

    when_i_click_change_course
    then_i_am_taken_to_the_change_course_page
    when_i_select_a_course_with_one_study_mode
    and_i_click_continue
    when_i_select_a_new_location
    and_i_click_continue
    then_the_conditions_page_is_loaded
    and_i_click_continue
    then_the_review_page_is_loaded

    and_i_can_confirm_the_new_course_selection
    and_i_can_confirm_the_new_study_mode_selection
    and_i_can_confirm_the_new_location_selection

    when_i_click_change_provider
    then_i_am_taken_to_the_change_provider_page

    when_i_select_a_different_provider
    and_i_click_continue
    when_i_select_a_different_course
    and_i_click_continue
    when_i_select_a_different_study_mode
    and_i_click_continue
    when_i_select_a_new_location
    and_i_click_continue
    then_the_conditions_page_is_loaded
    and_i_click_continue
    then_the_review_page_is_loaded

    and_i_can_confirm_the_new_provider_selection
    and_i_can_confirm_the_new_course_selection
    and_i_can_confirm_the_new_study_mode_selection
    and_i_can_confirm_the_new_location_selection

    when_i_send_the_offer
    then_i_see_that_the_offer_was_successfuly_made
    and_the_standard_conditions_are_created
  end

  def given_the_course_subject_requires_ske
    application_choice.course_option.course.subjects.delete_all
    application_choice.course_option.course.subjects << build(
      :subject, code: 'F1', name: 'Chemistry'
    )
  end

  def and_the_other_courses_subject_does_not_require_ske
    @provider_available_course.subjects.delete_all
    @provider_available_course.subjects << build(
      :subject, code: 'W1', name: 'Art and design'
    )
  end

  def then_the_ske_standard_flow_is_loaded
    expect(page).to have_current_path("/provider/applications/#{application_choice.id}/offer/ske-requirements/new", ignore_query: true)
  end

  def when_i_dont_select_any_ske_answer
    click_link_or_button 'Continue'
  end

  def then_i_see_a_error_message_to_select_if_ske_required
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select whether you require the candidate to do a course')
  end

  def when_i_select_no_ske_required
    choose 'No'
  end

  def and_i_click_back
    click_link_or_button 'Back'
  end

  def when_i_select_ske_is_required
    choose 'Yes'
  end

  def then_the_ske_reason_page_is_loaded
    expect(page).to have_current_path("/provider/applications/#{application_choice.id}/offer/ske-reason/new", ignore_query: true)
  end

  def when_i_dont_give_a_ske_reason
    click_link_or_button 'Continue'
  end

  def then_i_see_a_error_message_to_give_a_reason_for_ske
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select why the candidate needs to take a course')
  end

  def when_i_add_a_ske_reason
    choose t('provider_interface.offer.ske_reasons.different_degree', degree_subject: application_choice.current_course.subjects.first.name)
  end

  def then_the_ske_length_page_is_loaded
    expect(page).to have_current_path("/provider/applications/#{application_choice.id}/offer/ske-length/new", ignore_query: true)
  end

  def when_i_dont_answer_ske_length
    click_link_or_button 'Continue'
  end

  def then_i_see_a_error_message_to_give_a_ske_course_length
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select how long the course must be')
  end

  def when_i_answer_the_ske_length
    choose '8 weeks'
  end

  def subject_name
    application_choice.course_option.course.subjects.first&.name
  end

  def and_i_can_confirm_my_answers
    expect(page).to have_content('A* on Maths A Level')
  end

  def when_i_click_change_course
    @selected_course = @provider_available_course
    @selected_course_option = @provider_available_course_option

    within(all('.govuk-summary-list__row')[2]) do
      click_link_or_button 'Change'
    end
  end

  def and_i_can_confirm_the_new_course_selection
    within(all('.govuk-summary-list__row')[2]) do
      expect(page).to have_content(@selected_course.name_and_code)
    end
  end

  def and_i_can_confirm_the_new_study_mode_selection
    within(all('.govuk-summary-list__row')[3]) do
      expect(page).to have_content(@selected_course_option.study_mode.humanize)
    end
  end

  def and_i_can_confirm_the_new_location_selection
    within(all('.govuk-summary-list__row')[5]) do
      expect(page).to have_content(@selected_course_option.site.name_and_address(' '))
    end
  end

  def when_i_click_change_provider
    @selected_provider = @available_provider
    @selected_course = @selected_provider_available_course
    @selected_course_option = @selected_provider_available_course_option

    within(all('.govuk-summary-list__row')[1]) do
      click_link_or_button 'Change'
    end
  end

  def and_i_can_confirm_the_new_provider_selection
    within(all('.govuk-summary-list__row')[1]) do
      expect(page).to have_content(@selected_provider.name_and_code)
    end
  end

  def and_i_do_not_request_any_specific_references
    choose 'No'
  end

  def and_the_standard_conditions_are_created
    expect(page).to have_content('Fitness to train to teach check')
    expect(page).to have_content('Disclosure and Barring Service (DBS) check')
    expect(page).to have_content('Satisfactory references')
  end
end

require 'rails_helper'

RSpec.feature 'Provider makes an offer with SKE enabled' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper

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

  scenario 'Making an offer for the requested course option' do
    given_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface
    and_provider_ske_feature_flag_is_enabled

    given_the_provider_has_multiple_courses
    given_the_provider_user_can_offer_multiple_provider_courses

    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_awaiting_decision
    and_i_click_on_make_decision
    then_i_see_the_decision_page

    when_i_choose_to_make_an_offer

    then_the_ske_standard_flow_is_loaded
    when_i_dont_select_any_ske_answer
    then_i_should_see_a_error_message_to_select_if_ske_required

    when_i_select_no_ske_required
    and_i_click_continue
    then_the_conditions_page_is_loaded

    and_i_click_back

    when_i_select_ske_is_required
    and_i_click_continue
    then_the_ske_reason_page_is_loaded

    when_i_dont_give_a_ske_reason
    then_i_should_see_a_error_message_to_give_a_reason_for_ske

    when_i_add_a_ske_reason
    and_i_click_continue
    then_the_ske_length_page_is_loaded

    when_i_dont_answer_ske_length
    then_i_should_see_a_error_message_to_give_a_ske_course_length

    when_i_answer_the_ske_length
    and_i_click_continue
    then_the_conditions_page_is_loaded
    and_the_default_conditions_are_checked

    when_i_add_further_conditions
    and_i_add_and_remove_another_condition
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

  def and_provider_ske_feature_flag_is_enabled
    FeatureFlag.activate(:provider_ske)
  end

  def when_i_visit_the_provider_interface
    visit provider_interface_applications_path
  end

  def and_i_click_an_application_choice_awaiting_decision
    click_on application_choice.application_form.full_name
  end

  def and_i_click_on_make_decision
    click_on 'Make decision'
  end

  def then_i_see_the_decision_page
    expect(page).to have_content('Make a decision')
    expect(page).to have_content('Course applied for')
  end

  def when_i_choose_to_make_an_offer
    choose 'Make an offer'
    and_i_click_continue
  end

  def then_the_conditions_page_is_loaded
    expect(page).to have_content('Conditions of offer')
  end

  def and_the_default_conditions_are_checked
    expect(find("input[value='Fitness to train to teach check']")).to be_checked
    expect(find("input[value='Disclosure and Barring Service (DBS) check']")).to be_checked
  end

  def when_i_add_further_conditions
    click_on 'Add another condition'
    fill_in('provider_interface_offer_wizard[further_conditions][0][text]', with: 'A* on Maths A Level')
    expect(page.current_url).to include('#provider-interface-offer-wizard-further-conditions-0-text-field')
  end

  def and_i_add_and_remove_another_condition
    click_on 'Add another condition'
    fill_in('provider_interface_offer_wizard[further_conditions][1][text]', with: 'A condition that will be removed')
    click_on 'Remove condition 2'
  end

  def and_i_click_continue
    click_on t('continue')
  end

  def then_the_review_page_is_loaded
    expect(page).to have_content('Check and send offer')
  end

  def and_i_can_confirm_my_answers
    within('.app-offer-panel') do
      expect(page).to have_content('A* on Maths A Level')
    end
  end

  def when_i_select_a_new_location
    choose @selected_course_option.site_name
  end

  def and_i_can_confirm_the_new_location_selection
    within(all('.govuk-summary-list__row')[3]) do
      expect(page).to have_content(@selected_course_option.site.name_and_address(' '))
    end
  end

  def when_i_select_a_different_study_mode
    choose @selected_course_option.study_mode.humanize
  end

  def and_i_can_confirm_the_new_study_mode_selection
    within(all('.govuk-summary-list__row')[2]) do
      expect(page).to have_content(@selected_course_option.study_mode.humanize)
    end
  end

  def given_the_provider_has_multiple_courses
    @provider_available_course = create(:course, :open_on_apply, study_mode: :full_time, provider:, accredited_provider: ratifying_provider)
    create(:course, :open_on_apply, provider:)
    course_options = [create(:course_option, :full_time, course: @provider_available_course),
                      create(:course_option, :full_time, course: @provider_available_course),
                      create(:course_option, :full_time, course: @provider_available_course)]

    @provider_available_course_option = course_options.sample
  end

  def when_i_select_a_different_course
    choose @selected_course.name_and_code
  end

  alias_method :when_i_select_a_course_with_one_study_mode, :when_i_select_a_different_course

  def when_i_click_change_course
    @selected_course = @provider_available_course
    @selected_course_option = @provider_available_course_option

    within(all('.govuk-summary-list__row')[1]) do
      click_on 'Change'
    end
  end

  def then_i_am_taken_to_the_change_course_page
    expect(page).to have_content('Course')
  end

  def and_i_can_confirm_the_new_course_selection
    within(all('.govuk-summary-list__row')[1]) do
      expect(page).to have_content(@selected_course.name_and_code)
    end
  end

  def given_the_provider_user_can_offer_multiple_provider_courses
    @available_provider = create(:provider, :with_signed_agreement)
    create(:provider_permissions, provider: @available_provider, provider_user:, make_decisions: true)
    courses = [create(:course, study_mode: :full_time_or_part_time, provider: @available_provider, accredited_provider: ratifying_provider),
               create(:course, :open_on_apply, study_mode: :full_time_or_part_time, provider: @available_provider, accredited_provider: ratifying_provider)]
    @selected_provider_available_course = courses.sample

    course_options = [create(:course_option, :part_time, course: @selected_provider_available_course),
                      create(:course_option, :full_time, course: @selected_provider_available_course),
                      create(:course_option, :full_time, course: @selected_provider_available_course),
                      create(:course_option, :part_time, course: @selected_provider_available_course)]

    create(
      :provider_relationship_permissions,
      training_provider: provider,
      ratifying_provider:,
      ratifying_provider_can_make_decisions: true,
    )

    create(
      :provider_relationship_permissions,
      training_provider: @available_provider,
      ratifying_provider:,
      ratifying_provider_can_make_decisions: true,
    )

    @selected_provider_available_course_option = course_options.sample
  end

  def when_i_click_change_provider
    @selected_provider = @available_provider
    @selected_course = @selected_provider_available_course
    @selected_course_option = @selected_provider_available_course_option

    within(all('.govuk-summary-list__row')[0]) do
      click_on 'Change'
    end
  end

  def then_i_am_taken_to_the_change_provider_page
    expect(page).to have_content('Training provider')
  end

  def when_i_select_a_different_provider
    choose @selected_provider.name_and_code
  end

  def and_i_can_confirm_the_new_provider_selection
    within(all('.govuk-summary-list__row')[0]) do
      expect(page).to have_content(@selected_provider.name_and_code)
    end
  end

  def when_i_send_the_offer
    click_on 'Send offer'
  end

  def then_i_see_that_the_offer_was_successfuly_made
    within('.govuk-notification-banner--success') do
      expect(page).to have_content('Offer sent')
    end
  end

  def then_the_ske_standard_flow_is_loaded
    expect(page).to have_current_path("/provider/applications/#{application_choice.id}/offer/ske-standard-flow/new", ignore_query: true)
  end

  def when_i_dont_select_any_ske_answer
    click_on 'Continue'
  end

  def then_i_should_see_a_error_message_to_select_if_ske_required
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select if you require the candidate to do a course')
  end

  def when_i_select_no_ske_required
    choose 'No'
  end

  def and_i_click_back
    click_link 'Back'
  end

  def when_i_select_ske_is_required
    choose 'Yes'
  end

  def then_the_ske_reason_page_is_loaded
    expect(page).to have_current_path("/provider/applications/#{application_choice.id}/offer/ske-reason/new", ignore_query: true)
  end

  def when_i_dont_give_a_ske_reason
    click_on 'Continue'
  end

  def then_i_should_see_a_error_message_to_give_a_reason_for_ske
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select why the candidate needs to take a course')
  end

  def when_i_add_a_ske_reason
    choose t('provider_interface.offer.ske_reasons.new.different_degree', degree_subject: application_choice.current_course.name)
  end

  def then_the_ske_length_page_is_loaded
    expect(page).to have_current_path("/provider/applications/#{application_choice.id}/offer/ske-length/new", ignore_query: true)
  end

  def when_i_dont_answer_ske_length
    click_on 'Continue'
  end

  def then_i_should_see_a_error_message_to_give_a_ske_course_length
    expect(page).to have_content('There is a problem')
    expect(page).to have_content('Select how long the course should be')
  end

  def when_i_answer_the_ske_length
    choose '8 weeks'
  end
end

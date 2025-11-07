require 'rails_helper'

RSpec.describe 'Provider makes an offer on undergraduate applications' do
  include DfESignInHelpers
  include ProviderUserPermissionsHelper
  include OfferStepsHelper

  let(:provider) { @provider }
  let(:ratifying_provider) { @provider }
  let(:provider_user) { @provider_user }
  let(:application_choice) { @application_choice }

  scenario 'Making an offer for the requested course option' do
    given_there_is_an_undergraduate_application
    and_the_course_subject_requires_ske
    and_i_am_a_provider_user
    and_i_am_permitted_to_make_decisions_for_my_provider
    and_i_sign_in_to_the_provider_interface

    and_the_provider_user_can_offer_multiple_provider_courses
    when_i_visit_the_provider_interface
    and_i_click_an_application_choice_awaiting_decision
    and_i_click_on_make_decision
    then_i_see_the_decision_page

    when_i_choose_to_make_an_offer
    then_the_ske_questions_are_skipped
    then_the_conditions_page_is_loaded
    and_the_default_conditions_are_checked

    when_i_add_further_conditions
    and_i_add_and_remove_another_condition
    and_i_click_continue
    then_the_review_page_is_loaded
    and_i_can_confirm_my_answers

    when_i_send_the_offer
    then_i_see_that_the_offer_was_successfuly_made
  end

  def given_there_is_an_undergraduate_application
    @provider_user = create(:provider_user, :with_dfe_sign_in)
    @provider = @provider_user.providers.first
    @ratifying_provider = create(:provider)
    course = build(:course, :teacher_degree_apprenticeship, provider: @provider, accredited_provider: @ratifying_provider)
    course_option = build(:course_option, course:)
    @application_choice = create(:application_choice, :awaiting_provider_decision, course_option:)
  end

  def and_the_course_subject_requires_ske
    @application_choice.course_option.course.subjects.delete_all
    @application_choice.course_option.course.subjects << build(
      :subject, code: 'F1', name: 'Chemistry'
    )
  end

  def and_i_am_a_provider_user
    user_exists_in_dfe_sign_in(email_address: @provider_user.email_address)
  end

  def and_the_provider_user_can_offer_multiple_provider_courses
    create(
      :provider_relationship_permissions,
      training_provider: @provider,
      ratifying_provider: @ratifying_provider,
      ratifying_provider_can_make_decisions: true,
    )
  end

  def then_the_ske_questions_are_skipped
    expect(page).to have_no_content('SKE')
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
end

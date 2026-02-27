require 'rails_helper'

RSpec.describe 'Provider user views application with possible previous teacher trainings' do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'the possible previous teacher training is visible' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_received_an_application
    and_the_application_has_possible_previous_teacher_trainings
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    then_i_see_the_application_details
    and_i_see_the_possible_previous_teacher_training_card
    and_i_see_the_possible_previous_teacher_training_details_for_the_london_provider
    and_i_see_the_possible_previous_teacher_training_details_for_the_brixton_provider
  end

  scenario 'the application has no possible previous teacher trainings' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_i_am_permitted_to_see_applications_for_my_provider
    and_my_organisation_has_received_an_application
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    then_i_see_the_application_details
    and_i_do_not_see_the_possible_previous_teacher_training_card
  end

private

  def given_i_am_a_provider_user_with_dfe_sign_in
    provider_exists_in_dfe_sign_in
  end

  def and_i_am_permitted_to_see_applications_for_my_provider
    @provider_user = provider_user_exists_in_apply_database
  end

  def and_my_organisation_has_received_an_application
    @course_option = course_option_for_provider(
      provider: @provider_user.providers.first,
      course: build(:course, provider: @provider_user.providers.first),
    )

    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option: @course_option,
    )
  end

  def and_the_application_has_possible_previous_teacher_trainings
    create(
      :possible_previous_teacher_training,
      provider_name: 'The London Provider',
      started_on: '01/09/2024',
      ended_on: '01/01/2025',
      candidate: @application_choice.candidate,
    )

    create(
      :possible_previous_teacher_training,
      provider_name: 'The Brixton Provider',
      started_on: '01/09/2023',
      ended_on: '01/02/2024',
      candidate: @application_choice.candidate,
    )
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(@application_choice)
  end

  def then_i_see_the_application_details
    expect(page).to have_element(:h1, text: @application_choice.application_form.full_name)
    expect(page).to have_element(:p, text: @application_choice.course.name_and_code)
  end

  def and_i_see_the_possible_previous_teacher_training_card
    expect(page).to have_css('.app-section.possible-previous-teacher-training-card')

    within('.possible-previous-teacher-training-card') do
      expect(page).to have_element(
        :strong,
        text: 'This candidate may have previously started the below courses',
        class: 'govuk-warning-text__text',
      )
      expect(page).to have_element(:span, text: 'Why we think they may have trained before', class: 'govuk-details__summary-text')
      expect(page).to have_element(
        :p,
        text: 'A candidate with the same first name, last name and date of birth previously started the courses above.',
        class: 'govuk-body',
        visible: :all,
      )
      expect(page).to have_element(:p, text: 'This could be', class: 'govuk-body', visible: :all)
      expect(page).to have_element(:li, text: 'the same person', visible: :all)
      expect(page).to have_element(:li, text: 'a different person with the same details', visible: :all)
      expect(page).to have_element(
        :p,
        text: "Name and date of birth matches are not unique. They're particularly common for applicants from countries with lower name diversity.",
        class: 'govuk-body',
        visible: :all,
      )
      expect(page).to have_element(:h4, text: 'What you must do', class: 'govuk-heading-s', visible: :all)
      expect(page).to have_element(
        :p,
        text: 'Check if this is the same person who trained before:',
        class: 'govuk-body',
        visible: :all,
      )
      expect(page).to have_element(:li, text: 'contact their previous provider', visible: :all)
      expect(page).to have_element(:li, text: 'ask why they left or were removed', visible: :all)
      expect(page).to have_element(:li, text: 'decide if this is a safeguarding concern', visible: :all)
      expect(page).to have_element(
        :p,
        text: 'ITT criteria require you to check that candidates do not pose a safeguarding risk. This includes checking if they left a previous ITT programme due to safeguarding concerns.',
        class: 'govuk-body',
        visible: :all,
      )
    end
  end

  def and_i_see_the_possible_previous_teacher_training_details_for_the_london_provider
    within('.possible-previous-teacher-training-card') do
      expect(page).to have_element(:h3, text: 'The London Provider')

      expect(page).to have_element(:dt, text: 'Name of the training provider')
      expect(page).to have_element(:dd, text: 'The London Provider')

      expect(page).to have_element(:dt, text: 'Training dates')
      expect(page).to have_element(:dd, text: 'From September 2024 to January 2025')
    end
  end

  def and_i_see_the_possible_previous_teacher_training_details_for_the_brixton_provider
    within('.possible-previous-teacher-training-card') do
      expect(page).to have_element(:h3, text: 'The London Provider')

      expect(page).to have_element(:dt, text: 'Name of the training provider')
      expect(page).to have_element(:dd, text: 'The Brixton Provider')

      expect(page).to have_element(:dt, text: 'Training dates')
      expect(page).to have_element(:dd, text: 'From September 2023 to February 2024')
    end
  end

  def and_i_do_not_see_the_possible_previous_teacher_training_card
    expect(page).not_to have_css('.app-section.possible-previous-teacher-training-card')
  end
end

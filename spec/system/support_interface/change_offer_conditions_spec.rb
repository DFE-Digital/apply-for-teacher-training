require 'rails_helper'

RSpec.feature 'Add course to submitted application' do
  include DfESignInHelpers

  scenario 'Support user adds course to submitted application' do
    given_i_am_a_support_user
    and_there_is_an_offered_application_in_the_system
    and_i_visit_the_support_page

    when_i_click_on_the_application
    then_i_should_see_the_current_conditions

    when_i_click_on_change_conditions
    then_i_see_the_condition_edit_form_with_a_warning

    when_i_add_a_new_condition_and_click_update_conditions_without_a_support_ticket_url
    then_i_see_a_validation_error

    when_i_add_a_new_condition_and_click_update_conditions_with_a_support_ticket_url
    then_i_see_the_new_condition_as_well_as_the_original_ones

    when_i_click_on_change_conditions
    and_i_remove_all_conditions_and_click_update_conditions
    then_i_see_a_confirmation_page_about_candidate_being_recruited

    when_i_click_yes_im_sure
    then_i_see_that_the_candidate_has_been_recruited_and_conditions_have_been_removed
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_offered_application_in_the_system
    candidate = create :candidate, email_address: 'candy@example.com'

    Audited.audit_class.as_user(candidate) do
      @application_form = create(
        :completed_application_form,
        first_name: 'Candy',
        last_name: 'Dayte',
        candidate: candidate,
      )

      conditions = [build(:offer_condition, text: 'Be cool')]
      @application_choice = create(
        :application_choice,
        :with_offer,
        :with_accepted_offer,
        offer: build(:offer, conditions: conditions),
        application_form: @application_form,
      )
    end
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_the_application
    click_on 'Candy Dayte'
  end

  def then_i_should_see_the_current_conditions
    expect(page).to have_content("Conditions\nBe cool")
  end

  def when_i_click_on_change_conditions
    click_on 'Change conditions'
  end

  def then_i_see_the_condition_edit_form_with_a_warning
    expect(page).to have_current_path(
      support_interface_update_application_choice_conditions_path(@application_choice),
    )
  end

  def when_i_add_a_new_condition_and_click_update_conditions_without_a_support_ticket_url
    check 'Fitness to train to teach check'
    fill_in 'Condition 2', with: 'Learn to play piano'
    click_on 'Update conditions'
  end

  def then_i_see_a_validation_error
    expect(page).to have_current_path(support_interface_update_application_choice_conditions_path(@application_choice))
    expect(page).to have_content('Enter a Zendesk ticket URL')
  end

  def when_i_add_a_new_condition_and_click_update_conditions_with_a_support_ticket_url
    check 'Fitness to train to teach check'
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    fill_in 'Condition 2', with: 'Learn to play piano'
    click_on 'Update conditions'
  end

  def then_i_see_the_new_condition_as_well_as_the_original_ones
    expect(page).to have_current_path(support_interface_application_form_path(@application_choice.application_form_id))
    expect(page).to have_content(
      "Conditions\nFitness to train to teach check Be cool Learn to play piano",
    )
  end

  def and_i_remove_all_conditions_and_click_update_conditions
    uncheck 'Fitness to train to teach check'
    fill_in 'Condition 1', with: ''
    fill_in 'Condition 2', with: ''
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    click_on 'Update conditions'
  end

  def then_i_see_a_confirmation_page_about_candidate_being_recruited
    expect(page).to have_content('Are you sure you want to make this offer unconditional?')
    expect(page).to have_content('Because this offer has already been accepted removing all conditions will recruit this candidate immediately.')
  end

  def when_i_click_yes_im_sure
    click_on 'Yes I\'m sure - make offer unconditional and recruit candidate'
  end

  def then_i_see_that_the_candidate_has_been_recruited_and_conditions_have_been_removed
    expect(page).to have_current_path(support_interface_application_form_path(@application_choice.application_form_id))
    expect(page).to have_content('Recruited')
    expect(page).not_to have_content('Conditions')
  end
end

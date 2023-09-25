require 'rails_helper'

RSpec.feature 'Add course to submitted application' do
  include DfESignInHelpers

  scenario 'Support user adds course to submitted application' do
    given_i_am_a_support_user
    and_there_is_an_offered_application_in_the_system
    and_the_course_subject_requires_ske
    and_i_visit_the_support_page

    when_i_click_on_the_application
    then_i_should_see_the_current_conditions

    when_i_click_on_change_conditions
    then_i_see_the_condition_edit_form_with_a_warning

    when_i_add_a_new_ske_condition_and_click_update_conditions_without_a_support_ticket_url
    then_i_see_a_validation_error

    when_i_add_a_new_ske_condition_and_click_update_conditions_with_a_support_ticket_url
    then_i_see_the_new_ske_condition

    when_i_click_on_change_conditions
    and_i_change_the_length_of_the_ske_condition
    then_i_see_the_updated_ske_condition

    when_i_click_on_change_conditions
    and_i_delete_the_ske_condition
    then_i_see_that_the_ske_condition_has_been_removed
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_offered_application_in_the_system
    candidate = create(:candidate, email_address: 'candy@example.com')

    Audited.audit_class.as_user(candidate) do
      @application_form = create(
        :completed_application_form,
        first_name: 'Candy',
        last_name: 'Dayte',
        candidate:,
      )

      conditions = [build(:text_condition, description: 'Be cool', status: 'met')]
      @application_choice = create(
        :application_choice,
        :offered,
        :accepted,
        offer: build(:offer, conditions:),
        application_form: @application_form,
      )
    end
  end

  def and_the_course_subject_requires_ske
    @application_choice.course_option.course.subjects.delete_all
    @application_choice.course_option.course.subjects << build(
      :subject, code: 'C1', name: 'Biology'
    )
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_the_application
    click_link 'Candy Dayte'
  end

  def then_i_should_see_the_current_conditions
    expect(page).to have_content("Conditions\nBe cool")
  end

  def when_i_click_on_change_conditions
    click_link 'Change conditions'
  end

  def then_i_see_the_condition_edit_form_with_a_warning
    expect(page).to have_current_path(
      support_interface_update_application_choice_conditions_path(@application_choice),
    )
  end

  def when_i_add_a_new_ske_condition_and_click_update_conditions_without_a_support_ticket_url
    choose('Yes')
    choose('Their degree subject was not Biology')
    choose('8 weeks')
    click_button 'Update conditions'
  end

  def then_i_see_a_validation_error
    expect(page).to have_current_path(support_interface_update_application_choice_conditions_path(@application_choice))
    expect(page).to have_content('Enter a Zendesk ticket URL')
  end

  def when_i_add_a_new_ske_condition_and_click_update_conditions_with_a_support_ticket_url
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    choose('Yes')
    choose('Their degree subject was not Biology')
    choose('8 weeks')
    click_button 'Update conditions'
  end

  def then_i_see_the_new_ske_condition
    expect(page).to have_content('Subject knowledge enhancement course')
    expect(page).to have_content("Length\n8 weeks")
    expect(page).to have_content("Reason\nTheir degree subject was not Biology")
  end

  def and_i_change_the_length_of_the_ske_condition
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    choose('Yes')
    choose('Their degree subject was not Biology')
    choose('20 weeks')
    click_button 'Update conditions'
  end

  def then_i_see_the_updated_ske_condition
    expect(page).to have_content('Subject knowledge enhancement course')
    expect(page).to have_content("Length\n20 weeks")
    expect(page).to have_content("Reason\nTheir degree subject was not Biology")
  end

  def and_i_delete_the_ske_condition
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    choose('No')
    click_button 'Update conditions'
  end

  def then_i_see_that_the_ske_condition_has_been_removed
    expect(page).not_to have_content('Subject knowledge enhancement course')
  end
end

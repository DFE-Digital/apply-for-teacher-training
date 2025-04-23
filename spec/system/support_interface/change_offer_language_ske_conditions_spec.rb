require 'rails_helper'

RSpec.describe 'Add course to submitted application' do
  include DfESignInHelpers

  scenario 'Support user adds course to submitted application' do
    given_i_am_a_support_user
    and_there_is_an_offered_application_in_the_system
    and_the_language_course_subject_requires_ske
    and_i_visit_the_support_page

    when_i_click_on_the_application
    then_i_see_the_current_conditions

    when_i_click_on_change_conditions
    then_i_see_the_condition_edit_form_with_a_warning

    when_i_add_two_new_ske_conditions_and_click_update_conditions_with_a_support_ticket_url
    then_i_see_the_new_ske_conditions

    when_i_click_on_change_conditions
    and_i_change_the_length_of_the_ske_condition
    then_i_see_the_updated_ske_condition

    when_i_click_on_change_conditions
    and_i_remove_one_ske_condition
    then_i_see_only_one_condition_has_been_removed

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

  def and_the_language_course_subject_requires_ske
    @application_choice.course_option.course.subjects.delete_all
    @application_choice.course_option.course.subjects << build(
      :subject, code: '15', name: 'Modern Languages'
    )
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_the_application
    click_link_or_button 'Candy Dayte'
  end

  def then_i_see_the_current_conditions
    expect(page).to have_content('Conditions Be cool')
  end

  def when_i_click_on_change_conditions
    click_link_or_button 'Change conditions'
  end

  def then_i_see_the_condition_edit_form_with_a_warning
    expect(page).to have_current_path(
      support_interface_update_application_choice_conditions_path(@application_choice),
    )
  end

  def when_i_add_two_new_ske_conditions_and_click_update_conditions_with_a_support_ticket_url
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    check('French')
    within('#support-interface-conditions-form-ske-conditions-0-ske-required-french-conditional') do
      choose('Their degree subject was not French')
      choose('8 weeks')
    end
    check('German')
    within('#support-interface-conditions-form-ske-conditions-2-ske-required-german-conditional') do
      choose('Their degree subject was not German')
      choose('12 weeks')
    end
    click_link_or_button 'Update conditions'
  end

  def then_i_see_the_new_ske_conditions
    expect(page).to have_content('Subject knowledge enhancement course')
    expect(page).to have_content('Length 8 weeks')
    expect(page).to have_content('Reason Their degree subject was not German')
  end

  def and_i_change_the_length_of_the_ske_condition
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    check('French')
    within('#support-interface-conditions-form-ske-conditions-0-ske-required-french-conditional') do
      choose('Their degree subject was not French')
      choose('8 weeks')
    end
    check('German')
    within('#support-interface-conditions-form-ske-conditions-1-ske-required-german-conditional') do
      choose('Their degree subject was not German')
      choose('16 weeks')
    end
    click_link_or_button 'Update conditions'
  end

  def and_i_remove_one_ske_condition
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    uncheck 'French'
    click_link_or_button 'Update conditions'
  end

  def then_i_see_only_one_condition_has_been_removed
    expect(page).to have_content('Subject knowledge enhancement course')
    expect(page).to have_content('Reason Their degree subject was not German')
    expect(page).to have_no_content('Their degree subject was not French')
  end

  def then_i_see_the_updated_ske_condition
    expect(page).to have_content('Subject knowledge enhancement course')
    expect(page).to have_content('Length 16 weeks')
    expect(page).to have_content('Reason Their degree subject was not German')
  end

  def and_i_delete_the_ske_condition
    fill_in 'Zendesk ticket URL', with: 'becomingateacher.zendesk.com/agent/tickets/12345'
    uncheck('German')
    click_link_or_button 'Update conditions'
  end

  def then_i_see_that_the_ske_condition_has_been_removed
    expect(page).to have_no_content('Subject knowledge enhancement course')
  end
end

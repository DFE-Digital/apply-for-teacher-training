require 'rails_helper'

RSpec.describe 'Revert an accidental rejection' do
  include DfESignInHelpers
  include ActiveSupport::Testing::TimeHelpers

  scenario 'Revert a rejected application and return it to the `awaiting_provider_decision` status', :with_audited do
    given_i_am_a_support_user
    and_there_is_a_rejected_application

    when_i_visit_the_application_page
    then_i_see_a_revert_rejection_link

    when_i_click_revert_rejection
    then_i_see_a_confirmation_page_prompting_for_an_audit_comment

    when_i_click_continue
    then_i_see_a_validation_error

    when_i_add_an_audit_comment_and_click_continue
    then_i_see_the_application_page
    and_the_application_is_now_awaiting_provider_decision
  end

  scenario 'Can not revert a rejected application with a duplicate choice on the same course', :with_audited do
    given_i_am_a_support_user
    and_there_is_a_rejected_application
    and_there_is_a_duplicate_application_form_the_same_course

    when_i_visit_the_application_page
    then_i_see_a_revert_rejection_link

    when_i_click_revert_rejection
    then_i_see_a_confirmation_page_prompting_for_an_audit_comment

    when_i_add_an_audit_comment_and_click_continue
    then_i_see_an_error_regarding_an_active_duplicate_application
  end

  scenario 'Can revert a rejected application if it has a subsequent application form and it before find opens' do
    given_there_is_a_rejected_application
    and_the_application_has_a_subsequent_application

    travel_to(@subsequent_application_form.recruitment_cycle_timetable.find_opens_at - 1.day) do
      given_i_am_a_support_user
      when_i_visit_the_application_page_for_the_previous_application
      then_i_see_a_revert_rejection_link

      when_i_click_revert_rejection
      then_i_see_a_confirmation_page_prompting_for_an_audit_comment

      when_i_add_an_audit_comment_and_click_continue
      then_i_see_the_application_page
      and_the_application_is_now_awaiting_provider_decision
    end
  end

  scenario 'Can not revert a rejected application if it has a subsequent application form with application choices' do
    given_there_is_a_rejected_application
    and_the_application_has_a_subsequent_application
    and_the_subsequent_application_has_application_choices

    travel_to(@subsequent_application_form.recruitment_cycle_timetable.find_opens_at - 1.day) do
      given_i_am_a_support_user
      when_i_visit_the_application_page_for_the_previous_application
      then_i_can_not_see_a_revert_rejection_link
    end
  end

  scenario 'Can not revert a rejected application if it has a subsequent application form and it is after find opens' do
    given_there_is_a_rejected_application
    and_the_application_has_a_subsequent_application

    travel_to(@subsequent_application_form.recruitment_cycle_timetable.find_opens_at + 1.day) do
      given_i_am_a_support_user
      when_i_visit_the_application_page_for_the_previous_application
      then_i_can_not_see_a_revert_rejection_link
    end
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_a_rejected_application
    @application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
    )
    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application_form,
    )
    @application_choice.update!(status: :rejected, rejected_at: Time.zone.now)
  end
  alias_method :given_there_is_a_rejected_application, :and_there_is_a_rejected_application

  def and_there_is_a_duplicate_application_form_the_same_course
    _duplicate_application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application_form,
      course_option: @application_choice.course_option,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_form.id)
  end

  def then_i_see_a_revert_rejection_link
    expect(page).to have_link('Revert rejection')
  end

  def when_i_click_revert_rejection
    click_link_or_button('Revert rejection')
  end

  def then_i_see_a_confirmation_page_prompting_for_an_audit_comment
    expect(page).to have_current_path(
      support_interface_application_form_revert_rejection_path(
        application_form_id: @application_form.id,
        application_choice_id: @application_choice.id,
      ),
    )
    expect(page).to have_text('Are you sure you want to revert this rejection?')
  end

  def when_i_click_continue
    click_link_or_button 'Continue'
  end

  def then_i_see_a_validation_error
    expect(page).to have_current_path(
      support_interface_application_form_revert_rejection_path(
        application_form_id: @application_form.id,
        application_choice_id: @application_choice.id,
      ),
    )
    expect(page).to have_text('Enter a Zendesk ticket URL')
    expect(page).to have_text('Select that you have read the guidance')
  end

  def when_i_add_an_audit_comment_and_click_continue
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/123'
    check 'I have read the guidance'
    click_link_or_button 'Continue'
  end

  def then_i_see_the_application_page
    expect(page).to have_current_path(support_interface_application_form_path(@application_form.id))
  end

  def and_the_application_is_now_awaiting_provider_decision
    expect(@application_choice.reload.awaiting_provider_decision?).to be true
  end

  def then_i_see_an_error_regarding_an_active_duplicate_application
    within('.govuk-error-summary') do
      expect(page).to have_text('There is a problem')
      expect(page).to have_text(
        'This candidate has an active application for this course. They will need to delete the duplicate application before reverting this rejection.',
      )
    end
  end

  def and_the_application_has_a_subsequent_application
    @subsequent_application_form = create(
      :application_form,
      recruitment_cycle_year: @application_form.recruitment_cycle_year.next,
      previous_application_form: @application_form,
    )
  end

  def when_i_visit_the_application_page_for_the_previous_application
    visit support_interface_application_form_path(@application_form.id)
  end

  def then_i_can_not_see_a_revert_rejection_link
    expect(page).to have_no_link('Revert rejection')
  end

  def and_the_subsequent_application_has_application_choices
    create(:application_choice, application_form: @subsequent_application_form)
  end
end

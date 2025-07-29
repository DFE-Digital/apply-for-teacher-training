require 'rails_helper'

RSpec.describe 'Candidate responds to an invite' do
  include CandidateHelper

  before { FeatureFlag.activate(:candidate_preferences) }
  after { FeatureFlag.deactivate(:candidate_preferences) }

  scenario 'Candidate accepts an invite and creates a draft application' do
    given_i_am_signed_in
    and_i_am_on_the_application_choices_page
    when_i_click('Application sharing')
    then_i_can_see_my_invites

    when_i_click_view_invite_for(@invite)
    then_i_see_the_invite

    when_i_click('Continue')
    then_i_see_an_error_message_to_select_a_response

    when_i_select_yes_i_want_to_submit_an_application
    and_i_click('Continue')
    then_i_see_a_new_draft_application_form_for_the_course

    when_i_click('Application sharing')
    then_i_see_the_invites_index_page_with_a_link_to_my_application
  end

  scenario 'Candidate declines an invite' do
    given_i_am_signed_in
    and_i_am_on_the_application_choices_page
    when_i_click('Application sharing')
    then_i_can_see_my_invites

    when_i_click_view_invite_for(@invite)
    then_i_see_the_invite

    when_i_select_no_i_am_not_interested_in_this_course
    and_i_click('Continue')
    then_i_see_the_decline_reasons_page

    when_i_click('Continue')
    then_i_see_an_error_message_to_select_a_reason

    when_i_select_a_reason
    and_i_select_another_reason
    and_i_add_some_free_text
    and_i_click('Continue')
    then_i_return_to_the_invites_index
    and_i_see_a_flash_message
  end

  scenario 'Candidate clicks an email invite link for a closed course' do
    given_i_am_signed_in
    and_i_click_an_old_invite_link_for_an_unavailable_course
    then_i_see_the_course_unavailable_page
  end

private

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login

    course = create(:course, :open)
    create(:course_option, course:)

    application_form = create(
      :application_form,
      :completed,
      candidate: @current_candidate,
    )
    @invite = create(
      :pool_invite,
      course:,
      application_form:,
      status: 'published',
    )
    @unavailable_course_invite = create(
      :pool_invite,
      course: create(:course, :unavailable, application_status: 'closed'),
      course_open: false,
      application_form:,
      status: 'published',
    )
    @applied_invite = create(
      :pool_invite,
      :with_application_choice,
      course: create(:course, :open),
      application_form:,
      status: 'published',
    )
  end

  def and_i_am_on_the_application_choices_page
    visit candidate_interface_application_choices_path
  end

  def when_i_click(button)
    click_link_or_button button
  end
  alias_method :and_i_click, :when_i_click

  def then_i_can_see_my_invites
    expect(page).to have_content('Application sharing')

    within ".govuk-task-list__item##{@invite.id}" do
      expect(page).to have_content(
        "#{@invite.provider_name} #{@invite.course_name_code_and_study_mode}",
      )
      expect(page).to have_link(
        'View invite',
        href: edit_candidate_interface_invite_path(@invite),
      )
    end

    within ".govuk-task-list__item##{@applied_invite.id}" do
      expect(page).to have_content(
        "#{@applied_invite.provider_name} #{@applied_invite.course_name_code_and_study_mode}",
      )
      expect(page).to have_link(
        'View application',
        href: candidate_interface_course_choices_course_review_path(
          @applied_invite.application_choice,
          return_to: 'invites',
        ),
      )
      expect(page).to have_content('Applied')
    end
  end

  def then_i_see_the_invite
    expect(page).to have_content "Your invite from #{@invite.course.provider.name}"
  end

  def then_i_see_my_application
    expect(page).to have_content "Your application to #{@applied_invite.application_choice.provider.name}"
  end

  def when_i_select_yes_i_want_to_submit_an_application
    choose 'Yes I want to submit an application to this course'
  end

  def when_i_click_view_invite_for(invite)
    within ".govuk-task-list__item##{invite.id}" do
      click_link 'View invite'
    end
  end

  def and_i_click_an_old_invite_link_for_an_unavailable_course
    visit edit_candidate_interface_invite_path(@unavailable_course_invite)
  end

  def then_i_see_the_course_unavailable_page
    expect(page).to have_content "#{@unavailable_course_invite.course.name_and_code} has closed"
  end

  def then_i_see_a_new_draft_application_form_for_the_course
    @invite.reload
    expect(page).to have_content "Your application to #{@invite.application_choice.provider.name}"
    expect(page).to have_content @invite.application_choice.course.name_and_code.to_s
    expect(page).to have_content 'Draft'
  end

  def then_i_see_the_invites_index_page_with_a_link_to_my_application
    @invite.reload
    expect(page).to have_content('Application sharing')

    within ".govuk-task-list__item##{@invite.id}" do
      expect(page).to have_content(
        "#{@invite.provider_name} #{@invite.course_name_code_and_study_mode}",
      )
      expect(page).to have_link(
        'View application',
        href: candidate_interface_course_choices_course_review_path(@invite.application_choice, return_to: 'invites'),
      )
    end
  end

  def when_i_select_no_i_am_not_interested_in_this_course
    choose 'No I am not interested in this course'
  end

  def then_i_see_the_decline_reasons_page
    expect(page).to have_content('Why are you not interested in this course invitation?')
  end

  def when_i_select_a_reason
    check 'I do not want to train to teach this subject'
  end

  def and_i_select_another_reason
    check 'Another reason'
    expect(page).to have_content('Details (optional)')
  end

  def and_i_add_some_free_text
    fill_in 'candidate_interface_fac_invite_decline_reasons_form[comment]', with: 'I appreciate the invite, but I am not looking to teach this subject'
  end

  def then_i_return_to_the_invites_index
    within ".govuk-task-list__item##{@invite.id}" do
      expect(page).to have_content(
        "#{@invite.provider_name} #{@invite.course_name_code_and_study_mode}",
      )
      expect(page).to have_link(
        'View course',
        href: @invite.course.find_url,
      )
    end
  end

  def and_i_see_a_flash_message
    expect(page).to have_content "You have declined #{@invite.course.name_and_code} at #{@invite.course.provider.name}"
    expect(page).to have_content 'If you have changed your mind you can still apply to this course'
    expect(page).to have_link('apply to this course', href: candidate_interface_course_choices_course_confirm_selection_path(@invite.course))
  end

  def then_i_see_an_error_message_to_select_a_response
    expect(page).to have_content 'Select whether you want to apply to this course or not'
  end

  def then_i_see_an_error_message_to_select_a_reason
    expect(page).to have_content 'Select at least one reason why you are not interested in this course'
  end
end

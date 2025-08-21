require 'rails_helper'

RSpec.describe 'Candidate views their invites' do
  include CandidateHelper

  before { FeatureFlag.activate(:candidate_preferences) }
  after { FeatureFlag.deactivate(:candidate_preferences) }

  scenario 'after apply deadline', time: after_apply_deadline do
    given_i_am_signed_in_without_in_flight_applications
    when_i_go_to_application_sharing
    then_i_see_the_carry_over_content
  end

  scenario 'list invites' do
    given_i_am_signed_in
    and_i_am_on_the_application_choices_page
    when_i_click('Application sharing')
    then_i_can_see_my_invites

    when_i_click('View application')
    then_i_see_my_application

    when_i_click('Back')
    then_i_can_see_my_invites

    when_i_click('View and respond')
    then_i_see_the_invite

    when_i_click('Back')
    then_i_can_see_my_invites
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login

    application_form = create(
      :application_form,
      :completed,
      candidate: @current_candidate,
    )
    @invite = create(
      :pool_invite,
      application_form:,
      course: create(:course, :open),
      status: 'published',
    )

    @applied_invite = create(
      :pool_invite,
      :with_application_choice,
      course: create(:course, :open),
      application_form:,
      status: 'published',
    )

    @declined_invite = create(
      :pool_invite,
      candidate_decision: 'declined',
      application_form:,
      status: 'published',
    )

    @course_closed_invite = create(
      :pool_invite,
      course_open: false,
      application_form:,
      status: 'published',
    )
  end

  def when_i_click(button)
    click_link_or_button button
  end

  def then_i_can_see_my_invites
    expect(page).to have_content('Application sharing')

    within ".govuk-task-list__item##{@invite.id}" do
      expect(page).to have_content(
        "#{@invite.provider_name} #{@invite.course_name_code_and_study_mode}",
      )
      expect(page).to have_link(
        'View and respond',
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
      expect(page).to have_content('Accepted')
    end

    within ".govuk-task-list__item##{@declined_invite.id}" do
      expect(page).to have_content(
        "#{@declined_invite.provider_name} #{@declined_invite.course_name_code_and_study_mode}",
      )
      expect(page).to have_link(
        'View course',
        href: @declined_invite.course.find_url,
      )
      expect(page).to have_content('Declined')
    end

    within ".govuk-task-list__item##{@course_closed_invite.id}" do
      expect(page).to have_content(
        "#{@course_closed_invite.provider_name} #{@course_closed_invite.course_name_code_and_study_mode}",
      )
      expect(page).to have_link(
        'View course',
        href: @course_closed_invite.course.find_url,
      )
      expect(page).to have_content('Closed')
    end
  end

  def then_i_see_the_invite
    expect(page).to have_content "Your invite from #{@invite.course.provider.name}"
  end

  def then_i_see_my_application
    expect(page).to have_content "Your application to #{@applied_invite.application_choice.provider.name}"
  end

  def and_i_am_on_the_application_choices_page
    visit candidate_interface_application_choices_path
  end

  def given_i_am_signed_in_without_in_flight_applications
    given_i_am_signed_in_with_one_login

    create(:application_form, :completed, candidate: @current_candidate)
  end

  def when_i_go_to_application_sharing
    visit candidate_interface_invites_path
  end

  def then_i_see_the_carry_over_content
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Update your details'
    end
  end
end

require 'rails_helper'

RSpec.describe 'Canddiate views their invites' do
  include CandidateHelper

  before { FeatureFlag.activate(:candidate_preferences) }
  after { FeatureFlag.deactivate(:candidate_preferences) }

  scenario 'list invites' do
    given_i_am_signed_in
    and_i_am_on_the_application_choices_page
    when_i_click('Application sharing')
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
      status: 'published',
    )

    @applied_invite = create(
      :pool_invite,
      :with_application_choice,
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
        'View course',
        href: @invite.course.find_url,
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

  def and_i_am_on_the_application_choices_page
    visit candidate_interface_application_choices_path
  end
end

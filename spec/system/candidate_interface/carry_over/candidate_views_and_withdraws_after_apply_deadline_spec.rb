require 'rails_helper'

RSpec.describe 'Views offer and withdraws before carrying over', time: CycleTimetableHelper.mid_cycle do
  include CandidateHelper

  scenario 'candidate is awaiting provider decision' do
    given_i_am_waiting_provider_decision
    and_the_apply_deadline_passes
    when_i_sign_in
    and_i_click_on_your_applications
    then_i_see_my_applications_page
    and_i_can_view_the_application

    when_i_withdraw_my_application
    and_i_click_on_your_applications
    then_i_see_the_carry_over_content
    and_my_application_is_withdrawn
  end

private

  def given_i_am_waiting_provider_decision
    @application_choice = create(:application_choice, :awaiting_provider_decision, :with_completed_application_form)
    @application_form = @application_choice.application_form
    @candidate = @application_form.candidate
  end

  def and_the_apply_deadline_passes
    advance_time_to(after_apply_deadline)
  end

  def when_i_sign_in
    login_as @candidate
    visit root_path
  end

  def and_i_click_on_your_applications
    click_on 'Your applications'
  end

  def then_i_see_my_applications_page
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_content 'Your applications'
    expect(page).to have_content 'Awaiting decision'
  end

  def and_i_can_view_the_application
    click_on @application_choice.provider.name
    expect(page)
      .to have_current_path(
        candidate_interface_course_choices_course_review_path(
          application_choice_id: @application_choice.id,
        ),
      )
    expect(page).to have_title("Your application to #{@application_choice.provider.name}")
    expect(page).to have_content('Awaiting decision')
  end

  def when_i_withdraw_my_application
    click_on 'withdraw this application'
    choose 'I plan to apply for teacher training in the future'
    click_on 'Continue'
    check 'My personal circumstances have changed'
    check 'I have concerns about the cost of doing the course'
    click_on 'Continue'
    click_on 'Yes I’m sure – withdraw this application'
  end

  def then_i_see_the_carry_over_content
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_element(:h1, text: 'The recruitment deadline has now passed')
    expect(@candidate.current_application.id).not_to eq @application_form.id
  end

  def and_my_application_is_withdrawn
    expect(@application_choice.reload.status).to eq 'withdrawn'
  end
end

require 'rails_helper'

RSpec.describe 'Views offer and withdraws before carrying over', time: CycleTimetableHelper.mid_cycle do
  include CandidateHelper

  before do
    FeatureFlag.deactivate(:new_candidate_withdrawal_reasons)
  end

  scenario 'candidate is awaiting provider decision' do
    given_i_am_waiting_provider_decision
    and_the_apply_deadline_passes
    when_i_sign_in
    and_i_click_on_your_applications
    then_i_see_my_applications_page
    and_i_can_view_the_application

    when_i_withdraw_my_application
    then_i_see_the_carry_over_page
    and_my_application_is_withdrawn

    and_i_can_carry_over_my_application
  end

private

  def given_i_am_waiting_provider_decision
    @application_choice = create(:application_choice, :awaiting_provider_decision)
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
    click_on 'Yes I’m sure – withdraw this application'
    check 'I do not want to train to be a teacher anymore'
    click_on 'Continue'
  end

  def then_i_see_the_carry_over_page
    expect(page).to have_current_path candidate_interface_start_carry_over_path
  end

  def and_my_application_is_withdrawn
    expect(page).to have_content 'Withdrawn'
    expect(@application_choice.reload.status).to eq 'withdrawn'
  end

  def and_i_can_carry_over_my_application
    click_on 'Update your details'
    expect(page).to have_current_path candidate_interface_details_path
    expect(@candidate.current_application.previous_application_form_id).to eq @application_form.id
  end
end

require 'rails_helper'

RSpec.describe 'Candidate does not act on offer between cycles' do
  include CandidateHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)
    @candidate = create(:candidate)
  end

  scenario 'Candidate is able to carry over application after offer is declined by default' do
    given_i_have_an_offer
    and_the_apply_deadline_has_passed
    when_i_sign_in
    and_i_navigate_to_my_applications
    then_i_cannot_carry_over_my_application
    and_i_see_offer

    when_the_reject_by_default_deadline_has_passed
    and_i_sign_in
    and_i_navigate_to_my_applications
    then_i_see_the_offer
    and_i_cannot_carry_over_my_application

    when_the_decline_by_default_date_has_passed
    and_i_sign_in
    and_i_navigate_to_my_applications
    then_i_am_able_to_start_carry_over
    then_i_see_my_declined_application
    and_i_can_carry_over_my_application
  end

  scenario 'Candidate with unsuccessful application and offer can only carry over once the offer has been declined by default' do
    given_i_have_an_offer_and_unsuccessful_applications
    and_the_apply_deadline_has_passed
    when_i_sign_in
    and_i_navigate_to_my_applications
    then_i_see_the_offer_and_unsuccessful_applications
    and_i_cannot_carry_over_my_application

    when_the_decline_by_default_date_has_passed
    and_i_sign_in
    then_i_see_my_declined_application
    and_i_see_unsuccessful_application_choices
    and_i_can_carry_over_my_application
  end

  scenario 'Candidate with outstanding offer that is declined by default can carry over in the next cycle' do
    given_i_have_an_offer
    and_the_apply_deadline_has_passed
    and_the_reject_by_default_deadline_has_passed
    and_the_decline_by_default_date_has_passed

    when_then_new_cycle_start
    and_i_sign_in
    then_i_see_my_declined_application
    and_i_can_carry_over_my_application
  end

private

  def given_i_have_an_offer
    @choice_with_offer = create(:application_choice, :offered, candidate: @candidate)
    @application_form = @choice_with_offer.application_form
  end
  alias_method :i_have_an_offer, :given_i_have_an_offer

  def given_i_have_an_offer_and_unsuccessful_applications
    i_have_an_offer
    create(:application_choice, :rejected, application_form: @application_form)
    create(:application_choice, :withdrawn, application_form: @application_form)
    create(:application_choice, :unsubmitted, application_form: @application_form)
  end

  def and_the_apply_deadline_has_passed
    advance_time_to(cancel_application_deadline + 1.second)
    EndOfCycle::CancelUnsubmittedApplicationsWorker.perform_sync
  end

  def when_i_sign_in
    logout
    login_as @candidate
    visit root_path
  end
  alias_method :and_i_sign_in, :when_i_sign_in

  def and_i_navigate_to_my_applications
    click_on 'Your applications'
  end

  def then_i_am_able_to_start_carry_over
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Update your details'
    end
  end

  def then_i_see_the_offer
    expect(page).to have_content @choice_with_offer.provider.name
    expect(page).to have_content 'Offer received'
    click_on @choice_with_offer.provider.name
    expect(page).to have_current_path(candidate_interface_offer_path(id: @choice_with_offer.id))
    click_on 'Your applications'
  end
  alias_method :i_see_the_offer, :then_i_see_the_offer
  alias_method :and_i_see_offer, :then_i_see_the_offer

  def then_i_see_the_offer_and_unsuccessful_applications
    i_see_the_offer
    i_see_unsuccessful_application_choices
  end

  def and_i_see_unsuccessful_application_choices
    expect(page).to have_content 'Application not sent'
    expect(page).to have_content 'Withdrawn'
    expect(page).to have_content 'Unsuccessful'
  end
  alias_method :i_see_unsuccessful_application_choices, :and_i_see_unsuccessful_application_choices

  def when_the_reject_by_default_deadline_has_passed
    advance_time_to(reject_by_default_run_date)
    EndOfCycle::RejectByDefaultWorker.perform_sync
  end
  alias_method :and_the_reject_by_default_deadline_has_passed, :when_the_reject_by_default_deadline_has_passed

  def when_the_decline_by_default_date_has_passed
    advance_time_to(decline_by_default_run_date)
    EndOfCycle::DeclineByDefaultWorker.perform_sync
  end
  alias_method :and_the_decline_by_default_date_has_passed, :when_the_decline_by_default_date_has_passed

  def when_then_new_cycle_start
    advance_time_to(after_find_opens(next_year))
  end

  def then_i_see_my_declined_application
    expect(page).to have_content 'The application deadline has passed'
    expect(page).to have_content 'Declined'
  end

  def and_i_can_carry_over_my_application
    click_on 'Update your details'
    expect(page).to have_current_path candidate_interface_details_path
  end

  def then_i_cannot_carry_over_my_application
    expect(page).to have_current_path candidate_interface_application_choices_path
    relative_next_timetable = @application_form.recruitment_cycle_timetable.relative_next_timetable
    apply_reopens_date = relative_next_timetable.apply_opens_at.to_fs(:day_and_month)
    expect(page).to have_content(
      "If your application(s) are not successful, or you do not accept any offers, you will be able to apply for courses starting in the #{relative_next_timetable.academic_year_range_name} academic year from #{apply_reopens_date}.",
    )
  end
  alias_method :and_i_cannot_carry_over_my_application, :then_i_cannot_carry_over_my_application
end

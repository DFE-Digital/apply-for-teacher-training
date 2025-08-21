require 'rails_helper'

RSpec.describe 'Carry over after rejecting offer', time: CycleTimetableHelper.mid_cycle do
  include CandidateHelper

  scenario 'candidate declines offers after apply deadline has passed' do
    given_i_have_two_offers
    and_the_apply_deadline_passes
    when_i_sign_in
    then_i_see_both_offers
    and_i_am_not_on_the_carry_over_page

    and_i_can_navigate_to_the_application_choices_page

    when_i_decline_the_first_offer
    then_the_first_offer_is_declined
    and_i_am_not_on_the_carry_over_page
    and_i_see_one_offer_and_one_declined_application

    and_i_can_navigate_to_the_application_choices_page

    when_i_decline_the_remaining_offer
    then_the_second_offer_is_declined
    then_i_see_the_carry_over_content
    and_i_am_able_to_carry_over_my_application
  end

private

  def given_i_have_two_offers
    @first_application_with_offer = create(:application_choice, :offered)
    @application_form = @first_application_with_offer.application_form
    @candidate = @application_form.candidate
    @second_application_with_offer = create(:application_choice, :offered, application_form: @application_form)
  end

  def and_the_apply_deadline_passes
    advance_time_to(after_apply_deadline)
  end

  def when_i_sign_in
    login_as @candidate
    visit root_path
  end

  def then_i_see_both_offers
    expect(page).to have_content @first_application_with_offer.current_provider.name
    expect(page).to have_content @second_application_with_offer.current_provider.name
    expect(page).to have_content('Offer received').twice
  end

  def then_the_first_offer_is_declined
    offer_is_declined(@first_application_with_offer.reload)
  end

  def then_the_second_offer_is_declined
    offer_is_declined(@second_application_with_offer.reload)
  end

  def offer_is_declined(application_with_offer)
    expect(page).to have_content 'You have declined your offer'
    expect(application_with_offer.reload.status).to eq 'declined'
  end

  def and_i_am_not_on_the_carry_over_page
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_content 'Your applications'
  end

  def and_i_can_navigate_to_the_application_choices_page
    visit candidate_interface_application_choices_path
    expect(page).to have_current_path candidate_interface_application_choices_path
  end

  def and_i_see_one_offer_and_one_declined_application
    expect(page).to have_content 'Declined'
    expect(page).to have_content('Offer received').once
  end

  def when_i_decline_the_first_offer
    decline_offer(@first_application_with_offer)
  end

  def when_i_decline_the_remaining_offer
    decline_offer(@second_application_with_offer)
  end

  def decline_offer(application_with_offer)
    click_on application_with_offer.current_provider.name
    expect(page).to have_content 'Details of offer'
    choose 'Decline offer'
    click_on 'Continue'
    click_on 'Yes I’m sure – decline this offer'
  end

  def then_i_see_the_carry_over_content
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      expect(page).to have_button 'Update your details'
    end
  end

  def and_i_am_able_to_carry_over_my_application
    click_on 'Update your details'
    expect(page).to have_current_path candidate_interface_details_path
  end
end

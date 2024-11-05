require 'rails_helper'

RSpec.describe 'Candidate accepts an offer' do
  include CourseOptionHelpers
  include CandidateHelper

  scenario 'Candidate views offer and changes referee email address to personal email address and ignores advice' do
    given_i_am_signed_in
    and_i_have_an_offer

    when_i_visit_my_applications
    and_i_click_to_view_my_application

    and_i_accept_the_offer
    then_i_see_my_references

    when_i_change_the_reference_email_address_to_a_personal_email_address
    then_i_see_the_interruption_page

    when_i_click_save_and_continue_without_changing_email_address
    then_i_see_my_references
    when_i_confirm_the_acceptance
    then_i_see_a_flash_message_telling_me_i_have_accepted_the_offer
  end

  scenario 'Candidate views offer and changes referee email address to personal email address and heeds advice' do
    given_i_am_signed_in
    and_i_have_an_offer

    when_i_visit_my_applications
    and_i_click_to_view_my_application

    and_i_accept_the_offer
    then_i_see_my_references
    when_i_change_the_reference_email_address_to_a_personal_email_address
    then_i_see_the_interruption_page
    when_i_click_go_back_and_change_the_email_address
    and_i_change_the_reference_email_address_to_a_professional_email_address
    then_i_see_my_references
    when_i_confirm_the_acceptance
    then_i_see_a_flash_message_telling_me_i_have_accepted_the_offer
  end

  scenario 'Candidate views offer and changes character reference email to personal email address' do
    given_i_am_signed_in
    and_i_have_an_offer
    and_my_references_are_character_references

    when_i_visit_my_applications
    and_i_click_to_view_my_application

    and_i_accept_the_offer
    then_i_see_my_references
    when_i_change_the_reference_email_address_to_a_personal_email_address
    then_i_see_my_references
    when_i_confirm_the_acceptance
    then_i_see_a_flash_message_telling_me_i_have_accepted_the_offer
  end

private

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_offer
    @application_form = create(
      :completed_application_form,
      first_name: 'Harry',
      last_name: 'Potter',
      candidate: @candidate,
      submitted_at: Time.zone.now,
      support_reference: '123A',
      recruitment_cycle_year: 2024,
    )

    @application_form.application_references.each do |ref|
      ref.update(feedback_status: 'not_requested_yet')
    end

    @course_option = course_option_for_provider_code(provider_code: 'ABC')

    @application_choice = create(
      :application_choice,
      :offered,
      course_option: @course_option,
      application_form: @application_form,
    )
  end

  def and_my_references_are_character_references
    @application_form.application_references.each do |ref|
      ref.update(referee_type: 'character')
    end
  end

  def and_i_accept_the_offer
    choose 'Accept offer and conditions'
    click_on t('continue')
  end

  def then_i_see_my_references
    @application_form.reload.application_references.creation_order.each do |reference|
      expect(page).to have_content(reference.name)
      expect(page).to have_content(reference.email_address)
      expect(page).to have_content(reference.relationship)
    end

    @reference = @application_form.application_references.first
  end

  def when_i_click_save_and_continue_without_changing_email_address
    click_on 'Save and continue'
  end

  def when_i_change_the_reference_email_address_to_a_personal_email_address
    click_on "Change email address for #{@reference.name}"
    fill_in "What is #{@reference.name}’s email address?", with: 'personal_email@gmail.com'
    click_on 'Save and continue'
  end

  def then_i_see_the_interruption_page
    expect(page).to have_content 'personal_email@gmail.com looks like a personal email address'
    expect(page).to have_content 'Many providers will not accept references from a personal email address (such as gmail.com).'
  end

  def when_i_click_go_back_and_change_the_email_address
    click_on 'Go back and change the email address'
  end

  def and_i_change_the_reference_email_address_to_a_professional_email_address
    fill_in "What is #{@reference.name}’s email address?", with: 'professional@open.ac.uk'
    click_on 'Save and continue'
  end

  def when_i_confirm_the_acceptance
    click_on 'Accept offer'
  end

  def then_i_see_a_flash_message_telling_me_i_have_accepted_the_offer
    expect(page).to have_content "You have accepted your offer for #{@application_choice.course.name_and_code} at #{@application_choice.provider.name}"
  end

  def back_link
    find('a', text: 'Back')[:href]
  end
end

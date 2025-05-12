require 'rails_helper'

RSpec.describe 'Candidate has references with personal email addresses when submitting' do
  include CandidateHelper

  scenario 'Candidate sees interruption and chooses to submit with personal references', time: mid_cycle do
    given_i_am_a_candidate_with_references_with_personal_email_addresses
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application_choice
    then_i_see_the_interruption_page

    when_i_choose_to_continue
    then_i_can_submit_my_application_choice
  end

  scenario 'Candidate sees interruption and chooses to edit personal references', time: mid_cycle do
    given_i_am_a_candidate_with_references_with_personal_email_addresses
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application_choice
    then_i_see_the_interruption_page

    when_i_choose_to_edit_my_references
    then_i_see_the_references_review_page
    and_i_can_change_the_a_references_email_address
  end

  scenario 'Candidate has already submitted an applications and does not see interruption', time: mid_cycle do
    given_i_am_a_candidate_with_references_with_personal_email_addresses
    and_i_have_a_submitted_application_choice
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application_choice
    then_i_do_not_see_the_interruption_page
    and_i_can_submit_my_application_choice
  end

  scenario 'Candidate has entered personal email address, but the reference is referee_type character', time: mid_cycle do
    given_i_am_a_candidate_with_references_with_personal_email_addresses
    and_my_references_are_character_references
    and_i_have_an_unsubmitted_application_choice
    when_i_review_my_application_choice
    then_i_do_not_see_the_interruption_page
    and_i_can_submit_my_application_choice
  end

private

  def given_i_am_a_candidate_with_references_with_personal_email_addresses
    @application_form = create(:completed_application_form, :with_degree_and_gcses)
    @application_form.update(submitted_at: nil)
    @candidate = @application_form.candidate
    references = create_list(:reference,
                             2,
                             :not_requested_yet,
                             referee_type: %w[academic professional].sample,
                             application_form: @application_form)
    @reference = references.first
    @reference.update(email_address: 'personal@yahoo.com')
  end

  def and_i_have_an_unsubmitted_application_choice
    @application_choice = create(:application_choice, status: 'unsubmitted', application_form: @application_form)
  end

  def and_my_references_are_character_references
    @application_form.application_references.each do |ref|
      ref.update(referee_type: 'character')
    end
  end

  def and_i_have_a_submitted_application_choice
    create(:application_choice, status: 'awaiting_provider_decision', application_form: @application_form)
    @application_form.update!(submitted_at: Time.zone.now)
  end

  def when_i_review_my_application_choice
    login_as(@candidate)
    visit root_path
    click_on 'Your applications'
    click_on @application_choice.provider.name
    click_on 'Review application'
  end

  def then_i_see_the_interruption_page
    expect(page).to have_content 'Give your application the best chance of success'
    expect(page).to have_content 'At least one of your references looks like it is using a personal email address.'
    expect(page).to have_content 'Many providers will not accept references from a personal email address (such as gmail.com).'
    expect(page).to have_content 'You should ask your references if they have a work email address you can use instead and update your application.'
    expect(page).to have_content 'If you cannot get another email address for the references you can still submit this application. You should explain why you are using a personal email address when you say how you know the person.'
  end

  def when_i_choose_to_edit_my_references
    click_on 'Update your references'
  end

  def when_i_choose_to_continue
    click_on 'Continue without editing'
  end

  def then_i_can_submit_my_application_choice
    expect(page).to have_content 'Do you want to submit your application?'
    click_on 'Confirm and submit application'
    expect(page).to have_content 'Application submitted'
    expect(@application_choice.reload.status).to eq 'awaiting_provider_decision'
    expect(@application_form.reload.submitted_at).not_to be_nil
  end

  def then_i_see_the_references_review_page
    expect(page).to have_current_path(candidate_interface_references_review_path)
    expect(page).to have_content 'Check your references'
  end

  def and_i_can_change_the_a_references_email_address
    click_on "Change email address for #{@reference.name}"
    fill_in "What is #{@reference.name}’s email address?", with: 'professional@ucl.ac.uk'
    click_on 'Save and continue'
    expect(page).to have_content 'professional@ucl.ac.uk'
  end

  def then_i_do_not_see_the_interruption_page
    expect(page).to have_no_content 'Give your application the best chance of success'
    expect(page).to have_current_path candidate_interface_course_choices_course_review_and_submit_path(@application_choice.id)
    expect(page).to have_content "Review your application to #{@application_choice.provider.name}"
  end

  def and_i_can_submit_my_application_choice
    click_on 'Confirm and submit application'
    expect(page).to have_content 'Application submitted'
  end
end

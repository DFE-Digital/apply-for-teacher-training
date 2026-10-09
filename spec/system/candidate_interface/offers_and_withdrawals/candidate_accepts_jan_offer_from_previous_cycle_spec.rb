require 'rails_helper'

RSpec.describe 'Candidate accepts January offer after new cycle starts' do
  include CandidateHelper
  include CourseOptionHelpers

  scenario 'candidate updates references' do
    given_a_candidate_has_submitted_an_application_choice_for_a_course_in_january
    and_the_new_cycle_starts
    when_the_candidate_signs_in
    then_they_create_a_new_application_form

    when_the_provider_makes_an_offer
    and_the_candidate_accepts_the_offer
    then_they_see_only_their_references_from_the_previous_cycle

    then_they_can_edit_a_reference_from_the_previous_cycle

    when_they_accept_the_offer
    then_they_only_see_their_references_from_the_previous_cycle

    and_they_can_edit_a_reference
    and_they_can_create_a_new_reference
  end

  def given_a_candidate_has_submitted_an_application_choice_for_a_course_in_january
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle)

    @current_candidate = create(:candidate)
    @previous_application_form = create(
      :application_form,
      :completed,
      candidate: @current_candidate,
      submitted_at: Time.zone.now,
    )
    @previous_application_form.application_references.update_all(feedback_status: 'not_requested_yet')

    january_start_year = @previous_application_form.recruitment_cycle_year + 1
    course_option = create(
      :course,
      :with_course_options,
      start_date: DateTime.new(january_start_year, 1, 10),
    ).course_options.first

    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      course_option:,
      application_form: @previous_application_form,
    )
  end

  def and_the_new_cycle_starts
    TestSuiteTimeMachine.travel_permanently_to(after_find_reopens)
  end

  def when_the_candidate_signs_in
    given_i_am_signed_in_with_one_login
  end

  def then_they_create_a_new_application_form
    expect(page).to have_current_path(candidate_interface_application_choices_path)

    @current_candidate.reload
    @new_application_form = @current_candidate.current_application

    expect(@new_application_form).not_to eq(@previous_application_form)
    expect(@new_application_form.application_references.count).to eq(@previous_application_form.application_references.count)
    expect(@current_candidate.active_previous_application).to eq(@previous_application_form)
  end

  def when_the_provider_makes_an_offer
    create(:offer, application_choice: @application_choice)
    @application_choice.offer!
  end

  def and_the_candidate_accepts_the_offer
    visit candidate_interface_application_choices_path
    click_link_or_button @application_choice.provider.name
    choose 'Accept offer and conditions'
    click_link_or_button 'Continue'
  end

  def then_they_see_only_their_references_from_the_previous_cycle
    expect(page).to have_current_path(candidate_interface_accept_offer_path(@application_choice))

    @previous_application_form.application_references.each do |reference|
      expect(page).to have_css("a[href*='/name/edit/#{reference.id}']")
    end

    @new_application_form.application_references.each do |reference|
      expect(page).to have_no_css("a[href*='/name/edit/#{reference.id}']")
    end
  end

  def then_they_can_edit_a_reference_from_the_previous_cycle
    @edited_reference = @previous_application_form.application_references.creation_order.first
    original_name = @edited_reference.name

    click_link_or_button "Change name for #{original_name}"
    fill_in 'What’s the name of the person who can give a reference?', with: 'Lisa Simpson'
    click_link_or_button 'Save and continue'

    expect(page).to have_current_path(candidate_interface_accept_offer_path(@application_choice))
    expect(page).to have_text('Lisa Simpson')
    expect(@edited_reference.reload.name).to eq('Lisa Simpson')
    expect(@new_application_form.application_references.pluck(:name)).to include(original_name)
    expect(@new_application_form.application_references.pluck(:name)).not_to include('Lisa Simpson')
  end

  def when_they_accept_the_offer
    click_link_or_button 'Accept offer'
    expect(page).to have_text("You have accepted your offer for #{@application_choice.course.name_and_code}")
  end

  def then_they_only_see_their_references_from_the_previous_cycle
    visit candidate_interface_application_offer_dashboard_path

    @previous_application_form.application_references.each do |reference|
      expect(page).to have_link(href: candidate_interface_application_offer_dashboard_reference_path(reference))
    end

    @new_application_form.application_references.each do |reference|
      expect(page).to have_no_link(href: candidate_interface_application_offer_dashboard_reference_path(reference))
    end
  end

  def and_they_can_edit_a_reference
    click_link_or_button 'Lisa Simpson'
    click_link_or_button 'Cancel request'
    click_link_or_button 'Cancel reference request'

    expect(page).to have_text('Request cancelled')
    expect(@edited_reference.reload.feedback_status).to eq('cancelled')
  end

  def and_they_can_create_a_new_reference
    visit candidate_interface_application_offer_dashboard_path
    click_link_or_button 'Request another reference'
    click_link_or_button 'Add reference'
    choose 'Character, such as a mentor or someone you know from volunteering'
    click_link_or_button 'Continue'
    fill_in 'What’s the name of the person who can give a reference?', with: 'Marge Simpson'
    click_link_or_button 'Save and continue'
    fill_in 'What is Marge Simpson’s email address?', with: 'marge.simpson@education.gov.uk'
    click_link_or_button 'Save and continue'
    fill_in 'How do you know Marge Simpson and how long have you known them?', with: 'Lord of the rings'
    click_link_or_button 'Save and continue'
    click_link_or_button 'Send reference request'

    new_reference = @previous_application_form.application_references.find_by(name: 'Marge Simpson')
    expect(new_reference).to be_present
    expect(new_reference.feedback_status).to eq('feedback_requested')
    expect(@new_application_form.application_references.find_by(name: 'Marge Simpson')).to be_nil
  end
end

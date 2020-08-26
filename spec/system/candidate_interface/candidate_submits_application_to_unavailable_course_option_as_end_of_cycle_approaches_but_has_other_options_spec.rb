require 'rails_helper'

RSpec.feature 'Stopping applications to unavailable course options as we approach the end of the cycle' do
  include CandidateHelper

  around do |example|
    given_applications_to_unavailable_courses_are_now_being_stopped(example)
  end

  scenario 'Candidate submits application to full course option but has another option that is not full' do
    given_i_have_an_application_that_is_ready_to_send_to_a_provider
    and_one_of_my_chosen_options_is_full
    when_the_system_sends_applications_to_providers
    then_my_application_to_the_full_option_is_cancelled
    and_i_receive_an_email_explaining_this
    and_my_other_option_is_being_considered
  end

  def given_applications_to_unavailable_courses_are_now_being_stopped(example)
    Timecop.freeze(
      EndOfCycleTimetable.date(:stop_applications_to_unavailable_course_options).end_of_day + 1.hour,
    ) do
      example.run
    end
  end

  def given_i_have_an_application_that_is_ready_to_send_to_a_provider
    @candidate = create(:candidate)
    create(
      :completed_application_form,
      :with_completed_references,
      application_choices_count: 2,
      references_count: 2,
      candidate: @candidate,
      edit_by: Time.zone.now - 1.hour,
    )
    @candidate.current_application.application_choices.each do |choice|
      ApplicationStateChange.new(choice).references_complete!
    end
    login_as(@candidate)
    visit candidate_interface_application_form_path
  end

  def and_one_of_my_chosen_options_is_full
    application_choice = @candidate.current_application.application_choices.first
    @option_that_is_full = application_choice.course_option
    @option_that_is_full.no_vacancies!
  end

  def when_the_system_sends_applications_to_providers
    SendApplicationsToProviderWorker.new.perform
  end

  def then_my_application_to_the_full_option_is_cancelled
    expect(@candidate.current_application.application_choices.first).to be_cancelled
  end

  def and_i_receive_an_email_explaining_this
    open_email(@candidate.email_address)

    explanatory_email = all_emails.find do |e|
      e.subject.include? "Application could not be sent for #{@option_that_is_full.course.name_and_code}"
    end

    expect(explanatory_email).to be_present
  end

  def and_my_other_option_is_being_considered
    other_option = @candidate.current_application.application_choices.last
    expect(other_option).to be_awaiting_provider_decision
  end
end

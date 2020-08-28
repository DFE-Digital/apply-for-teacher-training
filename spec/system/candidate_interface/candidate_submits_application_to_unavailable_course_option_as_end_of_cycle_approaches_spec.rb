require 'rails_helper'

RSpec.feature 'Stopping applications to unavailable course options as we approach the end of the cycle' do
  include CandidateHelper

  around do |example|
    given_applications_to_unavailable_courses_are_now_being_stopped(example)
  end

  scenario 'Candidate submits application to full course option' do
    given_i_have_an_application_that_is_ready_to_send_to_a_provider
    and_the_course_i_chose_is_now_full
    when_the_system_sends_applications_to_providers
    then_my_application_is_cancelled
    and_i_receive_an_email_explaining_this
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
      application_choices_count: 1,
      references_count: 2,
      candidate: @candidate,
      edit_by: Time.zone.now - 1.hour,
    )
    ApplicationStateChange.new(@candidate.current_application.application_choices.first).references_complete!
    login_as(@candidate)
    visit candidate_interface_application_form_path
  end

  def and_the_course_i_chose_is_now_full
    application_choice = @candidate.current_application.application_choices.first
    application_choice.course_option.no_vacancies!
  end

  def when_the_system_sends_applications_to_providers
    SendApplicationsToProviderWorker.new.perform
  end

  def then_my_application_is_cancelled
    expect(@candidate.current_application.application_choices.first).to be_cancelled
  end

  def and_i_receive_an_email_explaining_this
    open_email(@candidate.email_address)
    expect(current_email.subject).to include 'Find a different course and re-submit your application'
    expect(current_email.text).to include 'your recent application did not lead to a place on a course'
  end
end

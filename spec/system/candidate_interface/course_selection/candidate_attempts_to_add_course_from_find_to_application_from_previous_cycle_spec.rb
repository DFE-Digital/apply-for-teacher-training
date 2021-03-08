require 'rails_helper'

RSpec.feature 'Candidate attempts to add course via Find to application from previous cycle' do
  include CandidateHelper

  scenario 'The candidate cannot add course to an application from the previous cycle' do
    given_i_have_made_an_application_in_the_previous_cycle

    Timecop.travel('2021-03-02') do
      given_i_am_signed_in
      and_there_are_course_options

      when_i_visit_the_site_with_a_course_id_from_find
      then_i_see_that_my_application_must_be_carried_over
    end
  end

  def given_i_have_made_an_application_in_the_previous_cycle
    Timecop.travel('2020-08-15') do
      @previous_application_form = create(
        :application_form,
        :minimum_info,
        candidate: current_candidate,
        recruitment_cycle_year: 2020,
        support_reference: 'AB1234',
        submitted_at: nil,
      )
    end
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_are_course_options
    given_courses_exist
    @course = Course.find_by_code('2XT2')
  end

  def when_i_visit_the_site_with_a_course_id_from_find
    visit candidate_interface_apply_from_find_path(providerCode: @provider.code, courseCode: @course.code)
  end

  def then_i_see_that_my_application_must_be_carried_over
    expect(page).to have_content('Carry on with your application for courses starting in the 2021 to 2022 academic year.')
    expect(page).to have_content('Your courses have been removed. You can add them again now.')
    # Normally we'd avoid a trip directly to the db in a system spec,
    # this is here to prove a particular bug has been solved.
    expect(@previous_application_form.application_choices).to be_empty
  end
end

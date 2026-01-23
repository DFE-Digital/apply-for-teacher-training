require 'rails_helper'

RSpec.describe 'Candidate attempts to add course via Find to application from previous cycle' do
  include CandidateHelper

  scenario 'The candidate cannot add course to an application from many years ago' do
    given_i_have_made_an_application_in_the_previous_cycle
    and_a_new_cycle_starts
    and_i_am_signed_in
    and_there_are_course_options
    when_i_visit_the_site_with_a_course_id_from_find
    when_i_navigate_to_my_applications
    then_i_see_the_your_applications_page
  end

  def given_i_have_made_an_application_in_the_previous_cycle
    travel_temporarily_to('2020-08-15') do
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

  def and_a_new_cycle_starts
    advance_time_to(mid_cycle)
  end

  def and_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_there_are_course_options
    given_courses_exist
    @course = Course.find_by(code: '2XT2')
  end

  def when_i_visit_the_site_with_a_course_id_from_find
    visit candidate_interface_apply_from_find_path(providerCode: @provider.code, courseCode: @course.code)
  end

  def then_i_see_that_my_application_must_be_carried_over
    expect(page).to have_content('You started an application for courses starting in the 2020 to 2021 academic year, which have now closed.')
    expect(page).to have_content("Continue your application to apply for courses starting in the #{current_year} to #{next_year} academic year instead.")

    # Normally we'd avoid a trip directly to the db in a system spec,
    # this is here to prove a particular bug has been solved.
    expect(@previous_application_form.application_choices).to be_empty
  end

  def then_i_see_the_your_applications_page
    expect(page).to have_current_path candidate_interface_application_choices_path
    expect(page).to have_element(:h1, text: 'Your applications')
    expect(page).to have_link('Add application', class: 'govuk-button')

    # Normally we'd avoid a trip directly to the db in a system spec,
    # this is here to prove a particular bug has been solved.
    expect(@previous_application_form.application_choices).to be_empty
  end

  def when_i_navigate_to_my_applications
    click_on 'Your applications'
  end
end

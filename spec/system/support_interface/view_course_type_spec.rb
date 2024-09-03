require 'rails_helper'

RSpec.describe 'View course choice' do
  include DfESignInHelpers

  before do
    given_i_am_a_support_user
  end

  scenario 'View postgraduate course choice' do
    given_there_is_an_application_choice_to_postgraduate_course
    when_i_visit_the_application_page
    and_i_see_the_course_is_postgraduate
  end

  scenario 'View undergraduate course choice' do
    given_there_is_an_application_choice_to_undergraduate_course
    when_i_visit_the_application_page
    and_i_see_the_course_is_undergraduate
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def given_there_is_an_application_choice_to_postgraduate_course
    application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
    )
    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form:,
    )
  end

  def given_there_is_an_application_choice_to_undergraduate_course
    application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
    )
    course_option = create(
      :course_option,
      course: create(:course, :teacher_degree_apprenticeship),
    )
    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form:,
      course_option:,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def and_i_see_the_course_is_postgraduate
    expect(page).to have_content('Course type Postgraduate')
  end

  def and_i_see_the_course_is_undergraduate
    expect(page).to have_content('Course type Undergraduate')
  end
end

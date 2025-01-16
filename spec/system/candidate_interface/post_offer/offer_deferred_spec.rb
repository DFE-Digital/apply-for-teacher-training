require 'rails_helper'
require_relative 'post_offer_helper'

RSpec.describe 'Post-offer dashboard' do
  include CandidateHelper
  include PostOfferHelper

  scenario 'Candidate offer is deferred' do
    given_i_am_signed_in_with_one_login
    and_i_have_an_accepted_offer_deferred

    when_i_visit_the_application_dashboard
    then_i_see_that_i_have_deferred_my_offer
    and_i_see_my_references
    and_i_see_my_offer_conditions
    and_i_see_the_publisher_contact_information
    and_i_see_a_link_to_view_the_application
    and_i_see_a_link_to_withdraw_from_the_course
  end

  def and_i_have_an_accepted_offer_deferred
    @application_form = create(:completed_application_form, candidate: @current_candidate)

    @application_choice = create(
      :application_choice,
      :offer_deferred,
      application_form: @application_form,
    )
  end

  def then_i_see_that_i_have_deferred_my_offer
    expect(page).to have_content("Your deferred offer for #{@application_choice.current_course.name_and_code}")
    expect(page).to have_content("You have chosen to defer your offer from #{@application_choice.course_option.course.provider.name} to study #{@application_choice.course.name_and_code}.")
  end
end

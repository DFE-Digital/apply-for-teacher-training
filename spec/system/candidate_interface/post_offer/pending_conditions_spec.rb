require 'rails_helper'
require_relative 'post_offer_helper'

RSpec.feature 'Post-offer dashboard' do
  include CandidateHelper
  include PostOfferHelper

  scenario 'Candidate offer is pending conditions' do
    given_i_am_signed_in
    and_i_have_an_accepted_offer_pending_conditions

    when_i_visit_the_application_dashboard
    then_i_see_that_i_have_accepted_my_offer
    and_i_should_see_my_references
    and_i_see_my_offer_conditions
    and_i_see_the_publisher_contact_information
    and_i_see_a_link_to_view_the_application
    and_i_see_a_link_to_withdraw_from_the_course
  end

  def and_i_have_an_accepted_offer_pending_conditions
    @application_form = create(:completed_application_form, candidate: @candidate)

    @application_choice = create(
      :application_choice,
      :pending_conditions,
      application_form: @application_form,
    )
  end
end

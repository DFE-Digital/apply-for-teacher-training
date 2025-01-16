require 'rails_helper'
require_relative 'post_offer_helper'

RSpec.describe 'Post-offer dashboard' do
  include CandidateHelper
  include PostOfferHelper

  scenario 'Candidate is recruited' do
    given_i_am_signed_in_with_one_login
    and_i_have_been_recruited

    when_i_visit_the_application_dashboard
    then_i_see_that_i_have_accepted_my_offer
    and_i_see_my_references
    and_i_see_my_offer_conditions
    and_i_see_the_publisher_contact_information
    and_i_see_a_link_to_view_the_application
    and_i_see_a_link_to_withdraw_from_the_course
  end

  def and_i_have_been_recruited
    @application_form = create(:completed_application_form, candidate: @current_candidate)

    @application_choice = create(
      :application_choice,
      :recruited,
      application_form: @application_form,
    )
  end
end

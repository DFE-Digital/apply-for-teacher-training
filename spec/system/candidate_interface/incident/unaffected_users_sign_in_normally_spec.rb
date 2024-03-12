require 'rails_helper'
require_relative 'incident_helper'

RSpec.feature 'User unaffected by incident' do
  include SignInHelper
  include CandidateHelper
  include IncidentHelper

  scenario 'user id > 46 behaves normally' do
    given_i_am_a_candidate_with_a_non_incident_id
    and_the_feature_flag_is_activated
    when_i_am_signed_in
    and_i_visit_my_details
    then_i_am_on_the_my_details_page
  end

  def given_i_am_a_candidate_with_a_non_incident_id
    @candidate = create(:candidate, id: 47)
    create(:application_form, candidate: @candidate)
  end
end

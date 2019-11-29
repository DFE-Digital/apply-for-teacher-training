require 'rails_helper'

RSpec.feature 'Candidate entering Science GCSE' do
  include CandidateHelper

  scenario 'Candidate enters a Science GCSE' do
    given_i_am_signed_in
    when_i_visit_the_site
    then_i_dont_see_science_gcse
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_dont_see_science_gcse
    expect(page).not_to have_content('Science GCSE or equivalent')
  end
end

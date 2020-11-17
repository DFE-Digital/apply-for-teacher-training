require 'rails_helper'

RSpec.feature 'View application between cycles' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Date.new(2020, 8, 1)) do
      example.run
    end
  end

  scenario 'Candidate submits their contact details' do
    given_i_am_signed_in
    and_i_visit_the_site
    then_i_should_not_see_the_applications_reopen_banner

    given_we_are_between_2020_and_2021_cycles
    and_i_logout
    and_i_am_signed_in
    and_i_visit_the_site
    then_i_should_see_the_applications_reopen_banner
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_should_not_see_the_applications_reopen_banner
    expect(page).not_to have_content 'Applications for courses starting this academic year have now closed'
  end

  def given_we_are_between_2020_and_2021_cycles
    Timecop.travel(1.month.from_now)
  end

  def and_i_logout
    logout
  end

  alias_method :and_i_am_signed_in, :given_i_am_signed_in

  def then_i_should_see_the_applications_reopen_banner
    expect(page).to have_content 'Applications for courses starting this academic year have now closed'
  end
end

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
    and_the_international_addresses_flag_is_active
    and_i_visit_the_site

    # when_i_fill_in_my_phone_number
    # and_i_submit_my_phone_number
    # and_i_select_live_in_uk

    given_we_are_between_2020_and_2021_cycles
    # and_i_revisit_my_application
    then_i_should_see_the_applications_closed_banner
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_the_international_addresses_flag_is_active
    FeatureFlag.activate('international_addresses')
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def given_we_are_between_2020_and_2021_cycles
    Timecop.travel(1.month.from_now)
  end

  def then_i_should_see_the_applications_closed_banner
    expect(page).to have_content 'Applications for courses starting this academic year have now closed'
  end
end

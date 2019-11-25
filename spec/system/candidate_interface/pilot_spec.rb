require 'rails_helper'

RSpec.feature 'Pilot' do
  scenario 'Candidate views the terms and conditions' do
    given_the_pilot_is_not_open

    when_i_visit_the_start_page
    then_i_see_a_page_saying_were_not_open

    when_i_visit_the_sign_up_page
    then_i_see_a_page_saying_were_not_open
  end

  def given_the_pilot_is_not_open
    FeatureFlag.deactivate('pilot_open')
  end

  def when_i_visit_the_start_page
    visit candidate_interface_start_path
  end

  def when_i_visit_the_sign_up_page
    visit candidate_interface_sign_up_path
  end

  def then_i_see_a_page_saying_were_not_open
    expect(page).to have_content 'Apply for teacher training is a new GOV.UK service being trialled with a small number of training providers in England.'
  end
end

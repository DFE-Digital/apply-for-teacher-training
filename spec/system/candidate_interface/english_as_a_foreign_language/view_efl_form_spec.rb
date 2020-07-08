require 'rails_helper'

RSpec.feature 'View EFL form' do
  include CandidateHelper

  scenario 'Candidate navigates to EFL form' do
    given_i_am_signed_in
    and_the_efl_feature_flag_is_active

    then_i_cannot_see_the_efl_section_link
    when_i_declare_a_non_english_nationality
    then_i_can_see_the_efl_section_link

    when_i_click_on_the_efl_section_link
    then_i_see_the_efl_form
  end
end

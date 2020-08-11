require 'rails_helper'

RSpec.feature 'User guidance' do
  include DfESignInHelpers

  scenario 'Support user can see user guidance' do
    given_i_am_a_support_user

    when_i_visit_the_guidance_page
    then_i_should_see_the_user_guidance
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def when_i_visit_the_guidance_page
    visit support_interface_guidance_path
  end

  def then_i_should_see_the_user_guidance
    expect(page).to have_content('Most practice in line with GDPR is common sense but the key messages are:')
  end
end

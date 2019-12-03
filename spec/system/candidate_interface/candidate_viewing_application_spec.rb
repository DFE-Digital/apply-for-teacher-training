require 'rails_helper'

RSpec.feature 'Viewing their new application' do
  include CandidateHelper

  scenario 'Signed in candidate with no application choices' do
    given_i_am_signed_in
    when_i_visit_the_site
    then_i_should_see_that_i_have_made_no_choices
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_should_see_that_i_have_made_no_choices
    expect(page).to have_content(t('application_form.courses.intro'))
  end
end

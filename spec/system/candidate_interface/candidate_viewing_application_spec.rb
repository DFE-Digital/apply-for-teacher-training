require 'rails_helper'

RSpec.feature 'Viewing their new application' do
  scenario 'Logged in candidate with no application choices' do
    given_i_am_signed_in
    when_i_visit_the_site
    then_i_should_see_that_i_have_made_no_choices
  end

  def given_i_am_signed_in
    candidate = create(:candidate)
    login_as(candidate)
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_should_see_that_i_have_made_no_choices
    # TODO: disabled because we're creating a application_choice for all
    # new applications.
    # expect(page).to have_content(t('application_form.courses'))
  end
end

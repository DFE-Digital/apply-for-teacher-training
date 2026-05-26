require 'rails_helper'

RSpec.describe 'View application state matrix' do
  include DfESignInHelpers

  scenario 'rendering the page' do
    given_i_am_signed_in_as_a_support_user
    when_i_visit_the_application_state_page
    then_i_see_the_application_state_page
    and_i_see_the_application_state_matrix
  end

private

  def when_i_visit_the_application_state_page
    click_on 'Documentation'
    click_on 'Application states'
  end

  def then_i_see_the_application_state_page
    expect(page).to have_current_path(support_interface_docs_application_states_path)
    expect(page).to have_element(
      :p,
      text: 'A matrix of each state an application can be in, and the permissions and restrictions of each state.',
      class: 'govuk-body-l',
    )
  end

  def and_i_see_the_application_state_matrix
    within('.govuk-table') do
      ApplicationStateChange::ApplicationState.all.each do |application_state|
        application_state_scopes.each do |scope|
          text = application_state.try(scope) ? 'Yes' : 'No'
          expect(page.find("##{application_state.id}_#{scope}_cell")).to have_text(text)
        end
      end
    end
  end

  def application_state_scopes
    members = ApplicationStateChange::ApplicationState.members.sort
    members.delete(:id)
    members
  end
end

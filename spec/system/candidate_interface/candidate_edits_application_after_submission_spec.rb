require 'rails_helper'

RSpec.feature 'A candidate edits their application' do
  include CandidateHelper

  scenario 'candidate selects to edit their application', sidekiq: true do
    given_the_edit_application_feature_flag_is_on

    given_i_am_signed_in_as_a_candidate
    and_i_have_a_completed_application

    when_i_visit_the_application_dashboard
    and_i_click_the_edit_link
    then_i_see_a_button_to_edit_my_application
  end

  def given_the_edit_application_feature_flag_is_on
    FeatureFlag.activate('edit_application')
  end

  def given_i_am_signed_in_as_a_candidate
    create_and_sign_in_candidate
  end

  def and_i_have_a_completed_application
    form = create(:completed_application_form, :with_completed_references, :without_application_choices, candidate: current_candidate)
    @application_choice = create(:application_choice, :ready_to_send_to_provider, application_form: form)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_form_path
  end

  def and_i_click_the_edit_link
    click_link t('application_complete.dashboard.edit_link')
  end

  def then_i_see_a_button_to_edit_my_application
    expect(page).to have_link(t('application_complete.edit_page.edit_button'))
  end
end

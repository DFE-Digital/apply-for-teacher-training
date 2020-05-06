require 'rails_helper'

RSpec.describe 'Candidate can see previous application on apply again' do
  scenario 'when a candidate visits their apply again application form there is a link to their previous application' do
    given_apply_again_is_active
    and_i_am_signed_in
    and_i_have_an_unsuccessful_apply1_application

    when_i_visit_my_application_complete_page
    and_i_click_on_apply_again
    and_i_click_on_start_now
    and_i_click_on_the_link_to_my_previous_application
    then_i_see_the_review_previous_application_page

    when_i_click_back
    then_i_see_my_current_application_page

    when_i_try_and_visit_the_page_with_another_candidate_id
    then_i_am_redirected_to_my_current_application_page
  end

  def given_apply_again_is_active
    FeatureFlag.activate('apply_again')
  end

  def and_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_unsuccessful_apply1_application
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create(:application_choice, :with_rejection, application_form: @application_form)
  end

  def when_i_visit_my_application_complete_page
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_link 'Do you want to apply again?'
  end

  def and_i_click_on_start_now
    click_button 'Start now'
  end

  def and_i_click_on_the_link_to_my_previous_application
    click_link 'First application'
  end

  def then_i_see_the_review_previous_application_page
    expect(page).to have_current_path(candidate_interface_application_review_previous_path(@candidate.id, @application_form.id))
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_see_my_current_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def when_i_try_and_visit_the_page_with_another_candidate_id
    candidate2 = create(:candidate)
    visit candidate_interface_application_review_previous_path(candidate2.id, @application_form.id)
  end

  def then_i_am_redirected_to_my_current_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end
end

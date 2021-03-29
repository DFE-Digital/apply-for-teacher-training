require 'rails_helper'

RSpec.describe 'Candidate can see their rejection reasons on apply again' do
  scenario 'when a candidate visits their apply again application form they can see apply1 rejection reasons' do
    given_i_am_signed_in
    and_i_have_an_apply1_application_with_3_rejections

    when_i_visit_my_application_complete_page
    and_i_click_on_apply_again
    and_i_click_go_to_my_application_form

    then_i_can_see_my_previous_rejection_reasons
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_apply1_application_with_3_rejections
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create_list(:application_choice, 3, :with_rejection, application_form: @application_form)
  end

  def when_i_visit_my_application_complete_page
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Apply again'
  end

  def and_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def then_i_can_see_my_previous_rejection_reasons
    expect(page).to have_content(@application_form.application_choices.first.rejection_reason)
    expect(page).to have_content(@application_form.application_choices.second.rejection_reason)
    expect(page).to have_content(@application_form.application_choices.third.rejection_reason)
  end
end

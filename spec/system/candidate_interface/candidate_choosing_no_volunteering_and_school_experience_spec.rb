require 'rails_helper'

RSpec.feature 'Choosing no volunteering and school experience' do
  include CandidateHelper

  scenario 'Candidate chooses no volunteering and school experience' do
    given_i_am_signed_in
    and_i_visit_the_site

    when_i_click_on_volunteering_with_children_and_young_people
    then_i_am_asked_if_i_have_experience_volunteering_with_young_people_or_in_school

    when_i_omit_choosing_if_i_have_experience
    then_i_see_validation_errors

    when_i_choose_no_experience
    and_i_submit_the_volunteering_experience_form
    then_i_see_how_to_get_school_experience
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_volunteering_with_children_and_young_people
    click_link t('page_titles.volunteering.short')
  end

  def then_i_am_asked_if_i_have_experience_volunteering_with_young_people_or_in_school
    expect(page).to have_content(t('application_form.volunteering.experience.label'))
  end

  def when_i_omit_choosing_if_i_have_experience
    click_button t('application_form.volunteering.experience.button')
  end

  def then_i_see_validation_errors
    expect(page).to have_content(
      t('activemodel.errors.models.candidate_interface/volunteering_experience_form.attributes.experience.blank'),
    )
  end

  def when_i_choose_no_experience
    choose 'No'
  end

  def and_i_submit_the_volunteering_experience_form
    click_button t('application_form.volunteering.experience.button')
  end

  def then_i_see_how_to_get_school_experience
    expect(page).to have_content('Get school experience')
  end
end

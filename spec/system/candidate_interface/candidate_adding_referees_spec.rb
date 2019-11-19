require 'rails_helper'

RSpec.feature 'Candidate adding referees' do
  include CandidateHelper

  scenario 'Candidate adds references' do
    given_i_am_signed_in
    and_i_visit_the_application_form

    given_i_have_no_existing_references_on_the_form
    when_i_click_on_referees
    i_see_intro_content_about_choosing_your_referees
    then_when_i_click_continue
    and_i_fill_in_name_and_email_address
    and_i_submit_the_form
    i_see_a_validation_error_on_relationship
    when_i_enter_a_relationship
    and_i_submit_the_form
    when_i_click_on_back_to_application
    i_see_referees_is_not_complete

    when_i_click_on_referees
    and_i_click_on_add_second_referee
    and_i_fill_in_all_required_fields
    and_i_submit_the_form
    i_see_both_referees
    then_when_i_click_continue
    i_see_referees_is_complete
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_have_no_existing_references_on_the_form
    expect(@current_candidate.application_forms.last.references.count).to eq(0)
  end

  def and_i_visit_the_application_form
    visit candidate_interface_application_form_path
  end

  def given_data_from_find_exists
    provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(:site, name: 'Main site', code: '-', provider: provider)
    course = create(:course, name: 'Primary', code: '2XT2', provider: provider)
    create(:course_option, site: site, course: course, vacancy_status: 'B')
  end

  def when_i_click_on_referees
    click_link 'Referees'
  end

  def i_see_intro_content_about_choosing_your_referees
    expect(page).to have_content('Choosing your referees')
  end

  def then_when_i_click_continue
    click_link 'Continue'
  end

  def and_i_click_on_add_referee
    click_link 'Add referee'
  end

  def when_i_click_on_back_to_application
    click_link 'Back to application'
  end

  def and_i_fill_in_name_and_email_address
    fill_in('Full name', with: 'AJP Taylor')
    fill_in('Email address', with: 'ajptaylor@example.com')
  end

  def and_i_submit_the_form
    click_button 'Save and continue'
  end

  def i_see_a_validation_error_on_relationship
    expect(page).to have_content t('activerecord.errors.models.reference.attributes.relationship.blank')
  end

  def when_i_enter_a_relationship
    fill_in(t('application_form.referees.relationship.label'), with: 'Thats my tutor, that is')
  end

  def i_see_referees_is_complete
    expect(page).to have_css('#referees-badge-id', text: 'Completed')
  end

  def i_see_referees_is_not_complete
    expect(page).not_to have_css('#referees-badge-id', text: 'Completed')
  end

  def and_i_click_on_add_second_referee
    click_link 'Add a second referee'
  end

  def and_i_fill_in_all_required_fields
    fill_in('Full name', with: 'Bill Lumbergh')
    fill_in('Email address', with: 'lumbergh@example.com')
    fill_in(t('application_form.referees.relationship.label'), with: 'manager for several years')
  end

  def i_see_both_referees
    expect(page).to have_content('AJP Taylor')
    expect(page).to have_content('ajptaylor@example.com')
    expect(page).to have_content('Thats my tutor, that is')

    expect(page).to have_content('Bill Lumbergh')
    expect(page).to have_content('lumbergh@example.com')
    expect(page).to have_content('manager for several years')
  end
end

require 'rails_helper'

RSpec.describe 'Entering personal details' do
  include CandidateHelper

  scenario 'The languages page is hidden' do
    given_i_am_signed_in
    and_my_application_is_in_a_state_where_languages_should_not_be_visible
    then_i_can_complete_personal_details_without_seeing_the_languages_page
    and_i_can_mark_the_section_complete
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
    visit candidate_interface_application_form_path
  end

  def and_my_application_is_in_a_state_where_languages_should_not_be_visible
    # This is the expected state for Personal Details -> Languages to be
    # hidden. See LanguagesSectionPolicy and its corresponding spec for more
    # detail.
    FeatureFlag.activate(:efl_section)
    expect(current_candidate.current_application.english_main_language).to eq nil
  end

  def then_i_can_complete_personal_details_without_seeing_the_languages_page
    click_link t('page_titles.personal_details')

    scope = 'application_form.personal_details'
    fill_in t('first_name.label', scope: scope), with: 'Lando'
    fill_in t('last_name.label', scope: scope), with: 'Calrissian'
    fill_in 'Day', with: '6'
    fill_in 'Month', with: '4'
    fill_in 'Year', with: '1937'
    click_button t('complete_form_button', scope: scope)
    select('British', from: t('nationality.label', scope: scope))
    find('details').click
    within('details') do
      select('American', from: t('second_nationality.label', scope: scope))
    end
    click_button t('complete_form_button', scope: scope)

    expect(page).to have_content 'Name'
    expect(page).to have_content 'Lando Calrissian'
    expect(page).to have_content 'British and American'
  end

  def and_i_can_mark_the_section_complete
    check t('application_form.completed_checkbox')
    click_button 'Continue'

    expect(page).to have_css('#personal-details-badge-id', text: 'Completed')
  end
end

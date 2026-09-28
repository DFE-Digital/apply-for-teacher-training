require 'rails_helper'

RSpec.describe 'Choosing visa or immigration status' do
  scenario 'non eu candidate who has the right to work' do
    given_i_am_logged_in_as_a_non_eu_candidate_who_has_the_right_to_work_or_study
    and_i_visit_the_immigration_status_edit_page
    when_i_choose_the_visa('Indefinite leave to remain in the UK')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Indefinite leave to remain in the UK')

    when_click_change_immigration_status
    and_i_choose_the_visa('Student visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Student visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Graduate visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Graduate visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Skilled Worker visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Skilled Worker visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Dependent on partner’s or parent’s visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Dependent on partner’s or parent’s visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Family visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Family visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('British National (Overseas) visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('British National (Overseas) visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('UK Ancestry visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('UK Ancestry visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('High Potential Individual visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('High Potential Individual visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Youth Mobility Scheme')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Youth Mobility Scheme')

    when_click_change_immigration_status
    and_i_choose_the_visa('India Young Professionals Scheme visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('India Young Professionals Scheme visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Ukraine Family Scheme or Ukraine Sponsorship Scheme visa')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Ukraine Family Scheme or Ukraine Sponsorship Scheme visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Afghan Citizens Resettlement Scheme (ACRS) or Afghan Relocations and Assistance Policy (ARAP)')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Afghan Citizens Resettlement Scheme (ACRS) or Afghan Relocations and Assistance Policy (ARAP)')

    when_click_change_immigration_status
    and_i_choose_the_visa('Refugee status')
    and_i_click_save_and_continue
    then_i_see_the_correct_visa_in_the_summary('Refugee status')
  end

  scenario 'eu candidate who has the right to work' do
    given_i_am_logged_in_as_a_eu_candidate_who_has_the_right_to_work_or_study
    and_i_visit_the_immigration_status_edit_page
    then_i_am_presented_with_the_correct_options
  end

  def when_click_change_immigration_status
    click_link_or_button('visa or immigration status')
  end

  def given_i_am_logged_in_as_a_non_eu_candidate_who_has_the_right_to_work_or_study
    @candidate = create(:candidate)
    @application_form = create(:application_form, first_nationality: 'Canadian', right_to_work_or_study: 'yes', candidate: @candidate)
    login_as(@candidate)
  end

  def given_i_am_logged_in_as_a_eu_candidate_who_has_the_right_to_work_or_study
    @candidate = create(:candidate)
    @application_form = create(:application_form, first_nationality: 'French', right_to_work_or_study: 'yes', candidate: @candidate)
    login_as(@candidate)
  end

  def then_i_am_presented_with_the_correct_options
    within('.govuk-fieldset') do
      expect(page).to have_text('EU settled status')
      expect(page).to have_text('EU pre-settled status')
      expect(page).to have_text('Indefinite leave to remain')
      expect(page).to have_text('Student visa')
      expect(page).to have_text('Graduate visa')
      expect(page).to have_text('Skilled Worker visa')
      expect(page).to have_text('Dependent on partner’s or parent’s visa')
      expect(page).to have_text('Family visa')
      expect(page).to have_text('UK Ancestry visa')
      expect(page).to have_text('High Potential Individual visa')
      expect(page).to have_text('Youth Mobility Scheme')
      expect(page).to have_text('Refugee status')
      expect(page).to have_text('Other')

      expect(page).to have_no_text('British National (Overseas) visa')
      expect(page).to have_no_text('India Young Professionals Scheme visa')
      expect(page).to have_no_text('Ukraine Family Scheme or Ukraine Sponsorship Scheme visa')
      expect(page).to have_no_text('India Young Professionals Scheme visa')
      expect(page).to have_no_text('Afghan Citizens Resettlement Scheme (ACRS) or Afghan Relocations and Assistance Policy (ARAP)')
    end
  end

  def and_i_visit_the_immigration_status_edit_page
    visit candidate_interface_immigration_status_edit_path
  end

  def when_i_choose_the_visa(visa)
    choose visa
  end

  alias_method :and_i_choose_the_visa, :when_i_choose_the_visa

  def and_i_click_save_and_continue
    click_link_or_button 'Save and continue'
  end

  def then_i_see_the_correct_visa_in_the_summary(visa_summary_text)
    within '.govuk-summary-list__row', text: 'immigration status' do
      expect(page).to have_text(visa_summary_text)
    end
  end
end

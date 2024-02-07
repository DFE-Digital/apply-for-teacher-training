require 'rails_helper'

RSpec.describe 'Choosing visa or immigration status' do
  scenario 'non eu candidate who and has right to work' do
    given_i_am_logged_in_as_a_non_eu_candidate_who_has_the_right_to_work_or_study
    and_i_visit_the_immigration_status_edit_page
    when_i_choose_the_visa('Indefinite leave to remain in the UK')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Indefinite leave to remain in the UK')

    when_click_change_immigration_status
    and_i_choose_the_visa('Student visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Student visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Graduate visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Graduate visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Skilled Worker visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Skilled Worker visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Dependent on partner’s or parent’s visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Dependent on partner’s or parent’s visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Family visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Family visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('British National (Overseas) visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('British National (Overseas) visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('UK Ancestry visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('UK Ancestry visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('High Potential Individual visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('High Potential Individual visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Youth Mobility Scheme')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Youth Mobility Scheme')

    when_click_change_immigration_status
    and_i_choose_the_visa('India Young Professionals Scheme visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('India Young Professionals Scheme visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Ukraine Family Scheme or Ukraine Sponsorship Scheme visa')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Ukraine Family Scheme or Ukraine Sponsorship Scheme visa')

    when_click_change_immigration_status
    and_i_choose_the_visa('Afghan citizens resettlement scheme or Afghan Relocations and Assistance Policy')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Afghan citizens resettlement scheme or Afghan Relocations and Assistance Policy')

    when_click_change_immigration_status
    and_i_choose_the_visa('Refugee Status')
    and_i_click_save_and_continue
    then_i_should_see_the_correct_visa_in_the_summary('Refugee Status')
  end

  def when_click_change_immigration_status
    click_link_or_button('visa or immigration status')
  end

  def given_i_am_logged_in_as_a_non_eu_candidate_who_has_the_right_to_work_or_study
    @candidate = create(:candidate)
    @application_form = create(:application_form, first_nationality: 'Canadian', right_to_work_or_study: 'yes', candidate: @candidate)
    login_as(@candidate)
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

  def then_i_should_see_the_correct_visa_in_the_summary(visa_summary_text)
    within '.govuk-summary-list__row', text: 'Immigration status' do
      expect(page).to have_text(visa_summary_text)
    end
  end
end

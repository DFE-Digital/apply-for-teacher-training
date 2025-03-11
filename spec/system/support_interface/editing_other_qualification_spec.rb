require 'rails_helper'

RSpec.describe 'Editing other qualification' do
  include DfESignInHelpers

  # :other_qualification has intentionally been chosen as a starting point for the application below because we are also
  # testing that other_uk_qualification_type is being reset to nil when the qualification_type is changed from "Other".

  before do
    given_i_am_a_support_user
    and_an_application_exists_with_an_other_level_qualification
    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_the_as_level_qualification
  end

  scenario 'update to AS Level', :with_audited do
    then_i_see_that_the_other_qualification_radio_has_been_preselected

    when_i_choose_as_level
    and_i_fill_in_the_as_level_details
    and_i_submit_the_form
    and_i_see_a_success_flash_message
    then_i_see_the_updated_as_level_details
    and_i_see_my_zendesk_ticket_in_the_audit_log
  end

  scenario 'update to GCSE' do
    when_i_choose_gcse
    and_i_fill_in_the_gcse_details
    and_i_submit_the_form
    and_i_see_a_success_flash_message
    then_i_see_the_updated_gcse_details
  end

  scenario 'update to A level' do
    when_i_choose_a_level
    and_i_fill_in_the_a_level_details
    and_i_submit_the_form
    and_i_see_a_success_flash_message
    then_i_see_the_updated_a_level_details
  end

  scenario 'update to Other UK qualification' do
    when_i_choose_other_uk_qualification
    and_i_fill_in_the_other_uk_details
    and_i_submit_the_form
    and_i_see_a_success_flash_message
    then_i_see_the_updated_other_uk_details
  end

  scenario 'update to Qualification from outside the UK' do
    when_i_choose_qualification_from_outside_the_uk
    and_i_fill_in_the_outside_uk_details
    and_i_submit_the_form
    and_i_see_a_success_flash_message
    then_i_see_the_updated_outside_uk_details
  end

  scenario 'audit validation' do
    when_i_submit_the_form
    then_i_see_the_audit_comment_validation_error
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists_with_an_other_level_qualification
    @form = create(:completed_application_form)
    create(:other_qualification, :non_uk, application_form: @form, institution_country: 'US')
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_the_as_level_qualification
    within('[data-qa="qualifications-table-a-levels-and-other-qualifications"]') do
      click_link_or_button 'Change'
    end
  end

  def then_i_see_that_the_other_qualification_radio_has_been_preselected
    expect(find_by_id('support-interface-application-forms-edit-other-qualification-form-qualification-type-non-uk-field')).to be_checked
  end

  def and_i_fill_in_the_as_level_details
    fill_in 'support-interface-application-forms-edit-other-qualification-form-subject-field', with: 'Best subject ever'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-grade-field', with: 'A*'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-award-year-field', with: '2023'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_fill_in_the_gcse_details
    fill_in 'support-interface-application-forms-edit-other-qualification-form-subject-field', with: 'My favourite GCSE'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-grade-field', with: 'C'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-award-year-field', with: '2022'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_fill_in_the_a_level_details
    fill_in 'support-interface-application-forms-edit-other-qualification-form-subject-field', with: 'really cool qualification'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-grade-field', with: 'B'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-award-year-field', with: '2021'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_fill_in_the_other_uk_details
    fill_in 'support-interface-application-forms-edit-other-qualification-form-other-uk-qualification-type-field', with: 'random qualification type'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-subject-field', with: 'some other qualification'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-grade-field', with: 'PASS'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-award-year-field', with: '2020'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_fill_in_the_outside_uk_details
    fill_in 'support-interface-application-forms-edit-other-qualification-form-non-uk-qualification-type-field', with: 'random qual from non uk country'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-subject-field', with: 'WAEC'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-grade-field', with: 'G'
    fill_in 'support-interface-application-forms-edit-other-qualification-form-award-year-field', with: '2019'
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_the_updated_as_level_details
    within('tbody.govuk-table__body') do
      within(first('tr.govuk-table__row')) do
        expect(find_all('td.govuk-table__cell')[0]).to have_text('AS level')
        expect(find_all('td.govuk-table__cell')[1]).to have_text('Best Subject Ever')
        expect(find_all('td.govuk-table__cell')[4]).to have_text('A*')
        expect(find_all('td.govuk-table__cell')[3]).to have_text('2023')
      end
    end
  end

  def then_i_see_the_updated_gcse_details
    within('tbody.govuk-table__body') do
      within(first('tr.govuk-table__row')) do
        expect(find_all('td.govuk-table__cell')[0]).to have_text('GCSE')
        expect(find_all('td.govuk-table__cell')[1]).to have_text('My Favourite Gcse')
        expect(find_all('td.govuk-table__cell')[4]).to have_text('C')
        expect(find_all('td.govuk-table__cell')[3]).to have_text('2022')
      end
    end
  end

  def then_i_see_the_updated_a_level_details
    within('tbody.govuk-table__body') do
      within(first('tr.govuk-table__row')) do
        expect(find_all('td.govuk-table__cell')[0]).to have_text('A level')
        expect(find_all('td.govuk-table__cell')[1]).to have_text('Really Cool Qualification')
        expect(find_all('td.govuk-table__cell')[4]).to have_text('B')
        expect(find_all('td.govuk-table__cell')[3]).to have_text('2021')
      end
    end
  end

  def then_i_see_the_updated_other_uk_details
    within('tbody.govuk-table__body') do
      within(first('tr.govuk-table__row')) do
        expect(find_all('td.govuk-table__cell')[0]).to have_text('random qualification type')
        expect(find_all('td.govuk-table__cell')[1]).to have_text('Some Other Qualification')
        expect(find_all('td.govuk-table__cell')[4]).to have_text('PASS')
        expect(find_all('td.govuk-table__cell')[3]).to have_text('2020')
      end
    end
  end

  def then_i_see_the_updated_outside_uk_details
    within('tbody.govuk-table__body') do
      within(first('tr.govuk-table__row')) do
        expect(find_all('td.govuk-table__cell')[0]).to have_text('random qual from non uk country')
        expect(find_all('td.govuk-table__cell')[1]).to have_text('Waec')
        expect(find_all('td.govuk-table__cell')[2]).to have_text('United States')
        expect(find_all('td.govuk-table__cell')[4]).to have_text('G')
        expect(find_all('td.govuk-table__cell')[3]).to have_text('2019')
      end
    end
  end

  def when_i_choose_as_level
    choose('support-interface-application-forms-edit-other-qualification-form-qualification-type-as-level-field')
  end

  def when_i_choose_gcse
    choose('support-interface-application-forms-edit-other-qualification-form-qualification-type-gcse-field')
  end

  def when_i_choose_a_level
    choose('support-interface-application-forms-edit-other-qualification-form-qualification-type-a-level-field')
  end

  def when_i_choose_other_uk_qualification
    choose('support-interface-application-forms-edit-other-qualification-form-qualification-type-other-field')
  end

  def when_i_choose_qualification_from_outside_the_uk
    choose('support-interface-application-forms-edit-other-qualification-form-qualification-type-non-uk-field')
  end

  def and_i_submit_the_form
    click_link_or_button 'Update'
  end

  alias_method :when_i_submit_the_form, :and_i_submit_the_form

  def and_i_see_a_success_flash_message
    expect(page).to have_content 'Other qualifications updated'
  end

  def and_i_see_my_zendesk_ticket_in_the_audit_log
    click_link_or_button 'History'
    expect(page).to have_content 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def then_i_see_the_audit_comment_validation_error
    within 'ul.govuk-error-summary__list' do
      expect(page).to have_link('Enter a Zendesk ticket URL')
    end
  end
end

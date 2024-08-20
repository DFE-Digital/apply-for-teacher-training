require 'rails_helper'

RSpec.describe 'Change maths GCSE' do
  include DfESignInHelpers

  scenario 'Change the maths GCSE on an application form', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision

    when_i_visit_the_application_page
    and_i_click_to_change_my_maths_gcse

    and_i_choose_no_qualification
    and_i_click_update
    then_i_see_a_validation_error_about_no_qualification

    and_i_added_that_candidate_is_currently_studying_for_the_gcse
    and_i_click_update
    then_i_see_a_validation_error_to_enter_details

    when_i_added_the_details_of_the_qualification
    and_i_add_the_zendesk_ticket_url
    and_i_click_update
    then_it_has_saved_missing_qualification_into_the_application_form

    and_i_click_to_change_my_maths_gcse
    and_i_add_the_candidate_is_not_studying_for_gcse
    and_i_add_the_zendesk_ticket_url
    and_i_click_update
    then_it_has_saved_missing_qualification_with_missing_explanation_into_the_application_form

    and_i_click_to_change_my_maths_gcse
    when_i_choose_uk_o_level
    and_i_click_update
    then_i_see_a_validation_error_about_uk_o_level

    when_i_add_an_award_year_greater_than_1988
    and_i_click_update
    then_i_see_a_validation_error_about_uk_o_level_award_year

    when_i_add_all_details_for_uk_o_level
    and_i_click_update
    then_it_has_saved_uk_o_level_into_the_application_form

    and_i_click_to_change_my_maths_gcse
    and_i_choose_scottish_national_gcse
    and_i_click_update
    then_i_see_a_validation_error_about_scottish_national_gcse

    when_i_add_all_details_for_scottish_national_gcse
    and_i_click_update
    then_it_has_saved_scottish_national_gcse_into_the_application_form

    and_i_click_to_change_my_maths_gcse
    and_i_choose_non_uk_gcse
    and_i_click_update
    then_i_see_a_validation_error_about_non_uk_gcse

    and_i_add_all_details_for_non_uk_gcse
    and_i_click_update
    then_it_has_saved_non_uk_gcse_into_the_application_form

    and_i_click_to_change_my_maths_gcse
    and_i_choose_another_uk_qualification
    and_i_click_update
    then_i_see_a_validation_error_about_another_uk_qualification

    and_i_add_all_details_for_another_uk_qualification
    and_i_click_update
    then_it_has_saved_another_uk_qualification_into_the_application_form

    and_i_click_to_change_my_maths_gcse
    and_i_choose_gcse
    and_i_click_update
    then_i_see_a_validation_error_about_gcse

    and_i_add_the_zendesk_ticket_url
    and_i_click_update

    then_it_has_saved_gcses_into_the_application_form
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_choice_awaiting_provider_decision
    @application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
    )
    @maths_gcse = create(:gcse_qualification, subject: 'maths', application_form: @application_form)

    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def then_i_see_a_change_maths_link
    expect(page).to have_link('Change')
  end

  def and_i_click_to_change_my_maths_gcse
    within('.app-edit-qualification') do
      click_link_or_button 'Change'
    end
  end
  alias_method :when_i_click_to_change_my_maths_gcse, :and_i_click_to_change_my_maths_gcse

  def when_i_click_update
    click_link_or_button 'Update details'
  end
  alias_method :and_i_click_update, :when_i_click_update

  def when_i_choose_uk_o_level
    choose 'UK O level (from before 1989)'
  end

  def and_i_choose_no_qualification
    choose 'I do not have a qualification in maths yet'
  end

  def then_i_see_a_validation_error_about_no_qualification
    expect(page).to have_content('Choose an option if candidate is currently studying for a GCSE')
  end

  def and_i_added_that_candidate_is_currently_studying_for_the_gcse
    choose 'Yes'
  end

  def then_i_see_a_validation_error_about_uk_o_level
    expect(page).to have_content('You must provide an audit comment')
    expect(page).to have_content('Enter your grade')
  end

  def then_i_see_a_validation_error_about_scottish_national_gcse
    expect(page).to have_content('You must provide an audit comment')
    expect(page).to have_content('Enter your grade')
    expect(page).to have_content('Enter the year you gained your qualification')
  end

  def when_i_add_an_award_year_greater_than_1988
    fill_in 'Award year', with: '1989'
  end

  def then_i_see_a_validation_error_about_uk_o_level_award_year
    expect(page).to have_content('Enter a year before 1989 - GCSEs replaced O levels in 1988')
  end

  def then_i_see_a_validation_error_to_enter_details
    expect(page).to have_content('Enter details of the qualification you are studying for')
  end

  def and_i_choose_scottish_national_gcse
    choose 'Scottish National 5'
    fill_in 'support_interface_gcse_form[grade]', with: ''
    fill_in 'Award year', with: ''
  end

  def when_i_add_all_details_for_scottish_national_gcse
    fill_in 'support_interface_gcse_form[grade]', with: 'CD'
    fill_in 'Award year', with: '2021'
    and_i_add_the_zendesk_ticket_url
  end

  def when_i_add_all_details_for_uk_o_level
    fill_in 'Grade', with: 'A'
    fill_in 'Award year', with: '1988'
    and_i_add_the_zendesk_ticket_url
  end

  def and_i_add_the_zendesk_ticket_url
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def when_i_added_the_details_of_the_qualification
    fill_in 'Details of the qualification you are studying for', with: 'I am studying'
  end

  def and_i_add_the_candidate_is_not_studying_for_gcse
    choose 'No'
    fill_in 'If you have other evidence of having maths skills at the required standard, give details (optional)', with: 'Many reasons listed'
  end

  def and_i_choose_non_uk_gcse
    choose 'Qualification from outside the UK'
  end

  def and_i_choose_another_uk_qualification
    choose 'Another UK qualification'
  end

  def and_i_choose_gcse
    choose 'GCSE'
  end

  def then_i_see_a_validation_error_about_non_uk_gcse
    expect(page).to have_content('You must provide an audit comment')
    expect(page).to have_content('Enter qualification name')
  end
  alias_method :then_i_see_a_validation_error_about_another_uk_qualification, :then_i_see_a_validation_error_about_non_uk_gcse

  def when_i_add_the_grades
    fill_in 'support_interface_gcse_form[grade_maths_single]', with: '4'
    fill_in 'support_interface_gcse_form[grade_maths_double]', with: '1-1'
    fill_in 'support_interface_gcse_form[grade_maths_language]', with: 'A'
    fill_in 'support_interface_gcse_form[grade_maths_literature]', with: 'B'
    fill_in 'support_interface_gcse_form[grade_maths_studies_single]', with: 'C'
    fill_in 'support_interface_gcse_form[grade_maths_studies_double]', with: 'A*A'
    fill_in 'support_interface_gcse_form[other_maths_gcse_name]', with: 'Awesome name'
    fill_in 'support_interface_gcse_form[grade_other_maths_gcse]', with: '3'
    and_i_add_the_zendesk_ticket_url
  end

  def then_i_see_a_validation_error_about_gcse_grades
    expect(page).to have_content('Enter your English (Single award) grade')
    expect(page).to have_content('Enter your English (Double award) grade')
  end

  def then_i_see_a_validation_error_about_gcse
    expect(page).to have_content('You must provide an audit comment')
  end

  def and_i_add_all_details_for_non_uk_gcse
    fill_in 'support_interface_gcse_form[non_uk_qualification_type]', with: 'Higher Secondary School Certificate'
    select 'Brazil', from: 'support_interface_gcse_form[institution_country]'
    fill_in 'UK ENIC reference number', with: '4000228363'
    choose 'GCE Advanced (A) level'
    and_i_add_the_zendesk_ticket_url
  end

  def and_i_add_all_details_for_another_uk_qualification
    fill_in 'support_interface_gcse_form[other_uk_qualification_type]', with: 'Other UK qualification'
    fill_in 'support_interface_gcse_form[grade]', with: 'D'
    fill_in 'Award year', with: '2022'
    and_i_add_the_zendesk_ticket_url
  end

  def then_it_has_saved_missing_qualification_into_the_application_form
    expect(page).to have_content('GCSE updated')

    expect(page).to have_current_path(support_interface_application_form_path(@application_form))

    @maths_gcse.reload
    expect(@maths_gcse.attributes.symbolize_keys).to include(
      qualification_type: 'missing',
      not_completed_explanation: 'I am studying',
      currently_completing_qualification: true,
      missing_explanation: nil,
      grade: nil,
      constituent_grades: nil,
      award_year: nil,
      institution_name: nil,
      institution_country: nil,
      other_uk_qualification_type: nil,
      non_uk_qualification_type: nil,
      enic_reference: nil,
      comparable_uk_qualification: nil,
    )
  end

  def then_it_has_saved_missing_qualification_with_missing_explanation_into_the_application_form
    expect(page).to have_content('GCSE updated')

    @maths_gcse.reload

    expect(@maths_gcse.attributes.symbolize_keys).to include(
      qualification_type: 'missing',
      currently_completing_qualification: false,
      missing_explanation: 'Many reasons listed',
      not_completed_explanation: nil,
      grade: nil,
      constituent_grades: nil,
      award_year: nil,
      institution_name: nil,
      institution_country: nil,
      other_uk_qualification_type: nil,
      non_uk_qualification_type: nil,
      enic_reference: nil,
      comparable_uk_qualification: nil,
    )
  end

  def then_it_has_saved_uk_o_level_into_the_application_form
    expect(page).to have_content('GCSE updated')

    @maths_gcse.reload
    expect(@maths_gcse.attributes.symbolize_keys).to include(
      qualification_type: 'gce_o_level',
      award_year: '1988',
      grade: 'A',
      not_completed_explanation: nil,
      currently_completing_qualification: nil,
      missing_explanation: nil,
    )
  end

  def then_it_has_saved_scottish_national_gcse_into_the_application_form
    expect(page).to have_content('GCSE updated')

    @maths_gcse.reload
    expect(@maths_gcse.attributes.symbolize_keys).to include(
      qualification_type: 'scottish_national_5',
      award_year: '2021',
      grade: 'CD',
      not_completed_explanation: nil,
      currently_completing_qualification: nil,
      missing_explanation: nil,
    )
  end

  def then_it_has_saved_non_uk_gcse_into_the_application_form
    expect(page).to have_content('GCSE updated')

    @maths_gcse.reload
    expect(@maths_gcse.attributes.symbolize_keys).to include(
      qualification_type: 'non_uk',
      non_uk_qualification_type: 'Higher Secondary School Certificate',
      comparable_uk_qualification: 'GCE Advanced (A) level',
      enic_reference: '4000228363',
      institution_country: 'BR',
    )
  end

  def then_it_has_saved_another_uk_qualification_into_the_application_form
    expect(page).to have_content('GCSE updated')

    @maths_gcse.reload
    expect(@maths_gcse.attributes.symbolize_keys).to include(
      qualification_type: 'other_uk',
      grade: 'D',
      other_uk_qualification_type: 'Other UK qualification',
      non_uk_qualification_type: nil,
      comparable_uk_qualification: nil,
      enic_reference: nil,
      institution_country: nil,
    )
  end

  def then_it_has_saved_gcses_into_the_application_form
    expect(page).to have_content('GCSE updated')

    @maths_gcse.reload
    expect(@maths_gcse.attributes.symbolize_keys).to include(
      qualification_type: 'gcse',
      grade: 'D',
      other_uk_qualification_type: nil,
      non_uk_qualification_type: nil,
      comparable_uk_qualification: nil,
      enic_reference: nil,
      institution_country: nil,
    )
  end
end

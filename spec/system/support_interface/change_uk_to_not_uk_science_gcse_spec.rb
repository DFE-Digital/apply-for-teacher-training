require 'rails_helper'

RSpec.describe 'Change science GCSE' do
  include DfESignInHelpers

  scenario 'changing from a UK science qualification to an international one', :with_audited do
    given_i_am_a_support_user
    and_there_is_an_application_choice_awaiting_provider_decision
    when_i_visit_the_application_page
    and_i_click_to_change_my_science_gcse
    and_i_add_a_double_award
    and_i_click_update
    then_it_has_saved_the_double_award_gcses_into_the_application_form

    when_i_click_to_change_my_science_gcse
    and_i_choose_non_uk_gcse
    and_i_add_all_details_for_non_uk_gcse
    and_i_click_update
    then_it_has_saved_non_uk_gcse_into_the_application_form
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_choice_awaiting_provider_decision
    @application_form = create(
      :application_form,
      submitted_at: Time.zone.now,
    )
    @science_gcse = create(:gcse_qualification, :science_triple_award, application_form: @application_form)

    @application_choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application_form,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@application_choice.application_form_id)
  end

  def then_i_see_a_change_science_link
    expect(page).to have_link('Change')
  end

  def and_i_click_to_change_my_science_gcse
    within('.app-edit-qualification') do
      click_link_or_button 'Change'
    end
  end
  alias_method :when_i_click_to_change_my_science_gcse, :and_i_click_to_change_my_science_gcse

  def and_i_click_update
    click_link_or_button 'Update details'
  end

  def and_i_add_the_zendesk_ticket_url
    fill_in 'Zendesk ticket URL', with: 'https://becomingateacher.zendesk.com/agent/tickets/12345'
  end

  def and_i_choose_non_uk_gcse
    choose 'Qualification from outside the UK'
  end

  def and_i_add_a_double_award
    choose 'GCSE'
    choose 'Double award'
    fill_in 'support_interface_gcse_form[double_award_grade]', with: 'CD'
    and_i_add_the_zendesk_ticket_url
  end

  def then_it_has_saved_the_double_award_gcses_into_the_application_form
    and_it_should_update_the_attributes(
      qualification_type: 'gcse',
      subject: 'science double award',
      grade: 'CD',
      constituent_grades: nil,
      other_uk_qualification_type: nil,
      non_uk_qualification_type: nil,
      comparable_uk_qualification: nil,
      enic_reference: nil,
      institution_country: nil,
    )
  end

  def and_i_add_all_details_for_non_uk_gcse
    fill_in 'support_interface_gcse_form[non_uk_qualification_type]', with: 'Higher Secondary School Certificate'
    select 'Brazil', from: 'support_interface_gcse_form[institution_country]'
    fill_in 'UK ENIC reference number', with: '4000228363'
    choose 'GCE Advanced (A) level'
    fill_in 'support_interface_gcse_form[grade]', with: '67%'
    and_i_add_the_zendesk_ticket_url
  end

  def then_it_has_saved_non_uk_gcse_into_the_application_form
    and_it_should_update_the_attributes(
      qualification_type: 'non_uk',
      non_uk_qualification_type: 'Higher Secondary School Certificate',
      comparable_uk_qualification: 'GCE Advanced (A) level',
      enic_reference: '4000228363',
      institution_country: 'BR',
      grade: '67%',
      subject: 'science',
    )
  end

  def when_i_choose_single_award
    choose 'Single award'
  end

  def when_i_add_the_single_award
    fill_in 'support_interface_gcse_form[single_award_grade]', with: '3'
  end

  def then_it_has_saved_the_single_award_gcses_into_the_application_form
    and_it_should_update_the_attributes(
      qualification_type: 'gcse',
      subject: 'science single award',
      grade: '3',
      constituent_grades: nil,
      other_uk_qualification_type: nil,
      non_uk_qualification_type: nil,
      comparable_uk_qualification: nil,
      enic_reference: nil,
      institution_country: nil,
    )
  end

  def and_it_should_update_the_attributes(attributes)
    expect(page).to have_content('GCSE updated')

    expect(page).to have_current_path(support_interface_application_form_path(@application_form))

    @science_gcse.reload
    expect(@science_gcse.attributes.symbolize_keys).to include(attributes)
  end
end

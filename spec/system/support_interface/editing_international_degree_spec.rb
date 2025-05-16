require 'rails_helper'

RSpec.describe 'Editing degree' do
  include DfESignInHelpers

  scenario 'Support user edits international degree', :with_audited do
    given_i_am_a_support_user
    and_an_application_exists_with_international_degree

    when_i_visit_the_application_page
    and_i_click_the_change_link_next_to_the_first_degree
    then_i_see_a_prepopulated_form

    when_i_choose('Yes')
    and_i_click('Update details')
    then_i_see_the_error('Enter an ENIC reference number')
    and_i_see_the_error('Select a comparable UK degree')

    when_i_enter_an_enic_reference_number
    and_i_choose('Bachelor (Ordinary) degree')
    and_i_enter_an_audit_comment
    and_i_click('Update details')
    then_i_see_a_success_message
    and_the_enic_reference_details_have_been_updated

    when_i_click_the_change_link_next_to_the_first_degree
    when_i_choose('No')
    and_i_click('Update details')
    then_i_see_the_error('Select a reason for not having an ENIC reference number')

    when_i_choose('Candidate will apply for one in the future')
    and_i_enter_an_audit_comment
    and_i_click('Update details')
    then_i_see_a_success_message
    and_the_enic_reason_has_been_updated
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_an_application_exists_with_international_degree
    @form = create(:completed_application_form)
    @degree = create(
      :non_uk_degree_qualification,
      enic_reference: nil,
      enic_reason: 'waiting',
      comparable_uk_degree: nil,
      application_form: @form,
    )
  end

  def when_i_visit_the_application_page
    visit support_interface_application_form_path(@form)
  end

  def and_i_click_the_change_link_next_to_the_first_degree
    within('[data-qa="degree-qualification"]') do
      click_link_or_button 'Change'
    end
  end
  alias_method :when_i_click_the_change_link_next_to_the_first_degree, :and_i_click_the_change_link_next_to_the_first_degree

  def then_i_see_a_prepopulated_form
    expect(page).to have_content("Edit #{@degree.subject.capitalize} degree")

    expect(page).to have_content 'Does the candidate have an ENIC reference number?'
  end

  def when_i_choose(text)
    choose text
  end
  alias_method :and_i_choose, :when_i_choose

  def and_i_click(text)
    click_on text
  end

  def then_i_see_the_error(text)
    expect(page.title).to include 'Error:'
    expect(page).to have_content 'There is a problem'
    expect(page).to have_content(text).twice
  end
  alias_method :and_i_see_the_error, :then_i_see_the_error

  def when_i_enter_an_enic_reference_number
    fill_in 'UK ENIC reference number', with: '4000228363'
  end

  def and_i_select_a_comparable_uk_degree
    choose 'Bachelor (Ordinary) degree'
  end

  def and_i_enter_an_audit_comment
    fill_in 'Audit log comment', with: 'Audit log comment'
  end

  def then_i_see_a_success_message
    expect(page).to have_content 'Success'
    expect(page).to have_content 'Degree updated'
  end

  def and_the_enic_reference_details_have_been_updated
    @degree.reload
    expect(@degree.enic_reference).to eq '4000228363'
    expect(@degree.enic_reason).to eq 'obtained'
    expect(@degree.comparable_uk_degree).to eq 'bachelor_ordinary_degree'
  end

  def and_the_enic_reason_has_been_updated
    @degree.reload
    expect(@degree.enic_reference).to be_nil
    expect(@degree.enic_reason).to eq 'maybe'
    expect(@degree.comparable_uk_degree).to be_nil
  end
end

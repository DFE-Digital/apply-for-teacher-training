require 'rails_helper'

RSpec.describe 'bulk unsubscribe Candidates' do
  include DfESignInHelpers

  scenario 'bulk unsubscribe candidates', :with_audited do
    given_i_am_a_support_user
    and_there_are_candidates_in_the_system
    and_i_visit_the_bulk_unsubscribe_page

    when_i_click_continue
    then_i_see_bulk_unsubscribe_form_validation_error

    when_i_enter_the_email_addresses
    and_i_click_continue
    then_i_can_see_candidates_are_unsubscribed
  end

private

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_are_candidates_in_the_system
    @candidate_1 = create(:candidate, email_address: 'candidate_1@email.address')
    @candidate_2 = create(:candidate, email_address: 'candidate_2@email.address')
    @candidate_3 = create(:candidate, email_address: 'candidate_3@email.address')
  end

  def and_i_visit_the_bulk_unsubscribe_page
    visit support_interface_path
    click_on 'Bulk unsubscribe candidates'
  end

  def when_i_click_continue
    click_on 'Continue'
  end

  alias_method :and_i_click_continue, :when_i_click_continue

  def then_i_see_bulk_unsubscribe_form_validation_error
    expect(page).to have_content("can't be blank")
  end

  def when_i_enter_the_email_addresses
    fill_in 'Email addresses', with: '
    candidate_1@email.address
    candidate_3@email.address
    '
  end

  def then_i_can_see_candidates_are_unsubscribed
    expect(page).to have_content('Candidates unsubscribed')
    expect(@candidate_1.reload).to be_unsubscribed_from_emails
    expect(@candidate_2.reload).not_to be_unsubscribed_from_emails
    expect(@candidate_3.reload).to be_unsubscribed_from_emails
  end
end

require 'rails_helper'

RSpec.feature 'See Duplicate candidate matches' do
  include DfESignInHelpers

  around do |example|
    @today = Time.zone.local(2021, 12, 24, 12)
    Timecop.freeze(@today) do
      example.run
    end
  end

  scenario 'Support agent visits Duplicate candidate matches page', sidekiq: true do
    given_i_am_a_support_user
    and_i_go_to_duplicate_matches_page
    then_i_should_see_a_message_that_there_are_no_matches

    when_there_are_candidates_with_duplicate_applications_in_the_system
    and_the_update_fraud_matches_worker_has_run
    and_i_go_to_duplicate_matches_page
    then_i_should_see_list_of_duplicates
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def then_i_should_see_a_message_that_there_are_no_matches
    expect(page).to have_content 'There are currently no duplicate applications'
  end

  def when_there_are_candidates_with_duplicate_applications_in_the_system
    @bob = create(:candidate, email_address: 'bob@example.com')
    @robert = create(:candidate, email_address: 'robert@example.com')

    @bobs_application_form = create(:application_form, candidate: @bob, first_name: 'Bob', last_name: 'Roberts', date_of_birth: '1998-08-08', postcode: 'W6 9BH', submitted_at: 7.days.ago)
    @roberts_application_form = create(:application_form, candidate: @robert, first_name: 'Robert', last_name: 'Roberts', date_of_birth: '1998-08-08', postcode: 'W6 9BH')
  end

  def and_the_update_fraud_matches_worker_has_run
    UpdateFraudMatchesWorker.perform_async
  end

  def and_i_go_to_duplicate_matches_page
    visit support_interface_duplicate_matches_path
  end

  def then_i_should_see_list_of_duplicates
    # TODO: 
  end
end

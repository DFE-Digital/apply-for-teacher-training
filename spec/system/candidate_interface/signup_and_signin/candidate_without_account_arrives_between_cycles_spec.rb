require 'rails_helper'

RSpec.feature 'Candidate without an acccount arrives after the apply1 deadline' do
  include CycleTimetableHelper

  around do |example|
    Timecop.freeze(after_apply_1_deadline) do
      example.run
    end
  end

  scenario 'Candidate is told they can apply when the next cycle launches' do
    given_the_pilot_is_open
    and_i_am_a_candidate_without_an_account

    when_i_arrive_at_the_site
    and_choose_that_i_dont_have_an_account
    then_i_am_told_that_applicatons_have_closed_for_this_cycle

    when_i_try_to_visit_the_sign_up_page
    then_i_am_told_that_applicatons_have_closed_for_this_cycle
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_i_am_a_candidate_without_an_account; end

  def when_i_arrive_at_the_site
    visit candidate_interface_create_account_or_sign_in_path
  end

  def and_choose_that_i_dont_have_an_account
    choose 'No, I need to create an account'
    click_button t('continue')
  end

  def then_i_am_told_that_applicatons_have_closed_for_this_cycle
    expect(page).to have_content 'Applications for courses starting this year have closed.'
  end

  def when_i_try_to_visit_the_sign_up_page
    visit candidate_interface_applications_closed_path
  end
end

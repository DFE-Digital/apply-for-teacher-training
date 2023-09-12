require 'rails_helper'

RSpec.feature 'Add comments to the application history', :with_audited, mid_cycle: false do
  include DfESignInHelpers

  scenario 'Support user adds a comment to the application audit page' do
    given_i_am_a_support_user
    and_there_is_an_application_in_the_system_logged_by_a_candidate
    and_i_visit_the_support_page

    when_i_click_on_an_application
    when_i_click_on_an_application_history
    when_i_click_on_add_comment
    and_i_fill_and_submit_the_comment_form
    then_i_should_see_my_comment_in_application_history
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_there_is_an_application_in_the_system_logged_by_a_candidate
    candidate = create(:candidate, email_address: 'alice@example.com')

    Audited.audit_class.as_user(candidate) do
      create(
        :application_form,
        first_name: 'Alice',
        last_name: 'Wunder',
        candidate:,
      )
    end

    TestSuiteTimeMachine.advance
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application
    click_on 'Alice Wunder'
  end

  def when_i_click_on_an_application_history
    click_on 'History'
  end

  def when_i_click_on_add_comment
    click_on 'Add comment'
  end

  def and_i_fill_and_submit_the_comment_form
    fill_in(
      'support_interface_application_comment_form[comment]',
      with: 'I did a thing to this application',
    )
    click_on 'Add comment'
  end

  def then_i_should_see_my_comment_in_application_history
    within('tbody tr:eq(1)') do
      expect(page).to have_content 'Comment on Application Form'
      expect(page).to have_content 'I did a thing to this application'
    end
  end
end

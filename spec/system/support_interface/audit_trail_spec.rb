require 'rails_helper'

RSpec.feature 'See applications' do
  scenario 'Support user visits application audit page' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_i_visit_the_support_page

    when_i_click_on_an_application_history
    then_i_should_be_on_the_application_history_page
  end

  def given_i_am_a_support_user
    page.driver.browser.authorize('test', 'test')
  end

  def and_there_are_applications_in_the_system
    @application_choice = create(:application_choice, application_form: create(:application_form, first_name: 'Alice', last_name: 'Wunder'))
    create(:application_choice, application_form: create(:application_form, first_name: 'Bob'))
    create(:application_choice, application_form: create(:application_form, first_name: 'Charlie'))
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def when_i_click_on_an_application_history
    find("a[href='#{support_interface_application_form_audit_path(@application_choice.application_form.id)}']").click
  end

  def then_i_should_be_on_the_application_history_page
    expect(page).to have_content 'Application History - Alice Wunder'
  end
end

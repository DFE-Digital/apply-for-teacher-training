require 'rails_helper'

RSpec.feature 'See applications' do
  scenario 'Provider visits application page' do
    given_i_am_a_support_user
    and_there_are_applications_in_the_system
    and_i_visit_the_support_page
    then_i_should_see_the_applications

    when_i_click_on_an_application
    then_i_should_be_on_the_application_view_page
  end

  def given_i_am_a_support_user
    page.driver.browser.authorize('test', 'test')
  end

  def and_there_are_applications_in_the_system
    create(:application_choice, application_form: create(:application_form, first_name: 'Alice', last_name: 'Wunder'))
    create(:application_choice, application_form: create(:application_form, first_name: 'Bob'))
    create(:application_choice, application_form: create(:application_form, first_name: 'Charlie'))
  end

  def and_i_visit_the_support_page
    visit support_interface_path
  end

  def then_i_should_see_the_applications
    expect(page).to have_content 'Alice'
    expect(page).to have_content 'Bob'
    expect(page).to have_content 'Charlie'
  end

  def when_i_click_on_an_application
    click_on 'Alice'
  end

  def then_i_should_be_on_the_application_view_page
    expect(page).to have_content "Alice Wunder's application"
  end
end

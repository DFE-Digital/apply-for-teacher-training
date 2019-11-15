require 'rails_helper'

RSpec.feature 'See applications' do
  include CourseOptionHelpers

  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_awaiting_provider_decision) {
    create(:application_choice, status: 'awaiting_provider_decision', course_option: course_option, application_form: create(:application_form, first_name: 'Alice', last_name: 'Wunder'))
  }
  let(:application_rejected) {
    create(:application_choice, status: 'rejected', course_option: course_option, application_form: create(:application_form, first_name: 'Alice', last_name: 'Wunder'))
  }

  scenario 'Provider can respond to application currently awaiting_provider_decision' do
    given_i_am_a_provider_user
    when_i_visit_a_application_with_status_awaiting_provider_decision
    then_i_can_see_its_status application_awaiting_provider_decision
    and_i_can_respond_to_the_application
  end

  scenario 'Provider cannot respond to application currently rejected' do
    given_i_am_a_provider_user
    when_i_visit_a_application_with_status_rejected
    then_i_can_see_its_status application_rejected
    and_i_cannot_respond_to_the_application
  end

  def given_i_am_a_provider_user
    # This is stubbed out for now in the controller.
  end

  def when_i_visit_a_application_with_status_awaiting_provider_decision
    visit provider_interface_application_choice_path(
      application_awaiting_provider_decision.id
    )
  end

  def when_i_visit_a_application_with_status_rejected
    visit provider_interface_application_choice_path(
      application_rejected.id
    )
  end

  def then_i_can_see_its_status(application)
    if application.status == 'awaiting_provider_decision'
      expect(page).to have_content 'Awaiting Provider Decision'
    elsif application.status == 'rejected'
      expect(page).to have_content 'Rejected'
    end
  end

  def and_i_can_respond_to_the_application
    expect(page).to have_content 'Respond to application'
  end

  def and_i_cannot_respond_to_the_application
    expect(page).not_to have_content 'Respond to application'
  end
end

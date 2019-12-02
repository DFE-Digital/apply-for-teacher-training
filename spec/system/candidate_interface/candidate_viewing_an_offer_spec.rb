require 'rails_helper'

RSpec.feature 'Candidate views an offer' do
  include CourseOptionHelpers

  let(:candidate) { create(:candidate) }
  let(:course_option) { course_option_for_provider_code(provider_code: 'ABC') }
  let(:application_form) { create(:application_form, candidate: candidate, submitted_at: DateTime.now) }

  before do
    create(
      :application_choice,
      status: 'offer',
      offer: { 'conditions' => ['Fitness to Teach check', 'Be cool'] },
      course_option: course_option,
      application_form: application_form,
    )
  end

  scenario 'Candidate views an offer for a course choice' do
    given_i_am_signed_in
    and_i_am_on_the_application_dashboard_and_i_have_an_offer
    then_i_see_the_view_and_respond_to_offer_link

    when_i_click_on_view_and_respond_to_offer_link
    then_i_see_the_offer
  end

  def given_i_am_signed_in
    login_as(candidate)
  end

  def and_i_am_on_the_application_dashboard_and_i_have_an_offer
    visit candidate_interface_application_complete_path
  end

  def then_i_see_the_view_and_respond_to_offer_link
    expect(page).to have_content(t('application_form.courses.view_and_respond_to_offer'))
  end

  def when_i_click_on_view_and_respond_to_offer_link
    click_link t('application_form.courses.view_and_respond_to_offer')
  end

  def then_i_see_the_offer
    provider = course_option.course.provider.name
    expect(page).to have_content(provider)
    expect(page).to have_content(t('page_titles.view_and_respond_to_offer'))
    expect(page).to have_content(
      "Do you want to respond to your offer to study #{course_option.course.name} (#{course_option.course.code}) at #{provider} now?",
    )
  end
end

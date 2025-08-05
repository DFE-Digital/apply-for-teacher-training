require 'rails_helper'

RSpec.describe 'Candidate submits the application' do
  include CandidateHelper

  before do
    FeatureFlag.activate(:candidate_preferences)
  end

  scenario 'Candidate with more than the max unsuccessful apps' do
    given_i_am_signed_in_with_one_login
    and_i_have_19_unsuccessful_applications

    when_i_have_completed_my_application_and_added_primary_as_course_choice
    and_i_go_to_submit_my_application
    then_i_can_see_my_application_has_been_successfully_submitted
    when_i_click('Back to your applications')
    and_i_can_see_i_have_three_choices_left

    when_my_application_is_rejected
    then_i_am_unable_to_add_any_further_choices
  end

  def and_i_have_19_unsuccessful_applications
    @current_candidate.application_forms << create(:application_form, :completed, :with_degree)
    @current_candidate.current_application.application_choices << build_list(:application_choice, 14, :withdrawn)
  end

  def when_i_have_completed_my_application_and_added_primary_as_course_choice
    @provider = create(:provider, name: 'Gorse SCITT', code: '1N1')
    site = create(
      :site,
      name: 'Main site',
      code: '-',
      provider: @provider,
      address_line1: 'Gorse SCITT',
      address_line2: 'C/O The Bruntcliffe Academy',
      address_line3: 'Bruntcliffe Lane',
      address_line4: 'MORLEY, lEEDS',
      postcode: 'LS27 0LZ',
    )
    @course = create(:course, :open, name: 'Primary', code: '2XT2', provider: @provider)
    @course_option = create(:course_option, site:, course: @course)
    @application_choice = create(:application_choice, :unsubmitted, course_option: @course_option, application_form: @current_candidate.current_application)
  end

  def and_i_go_to_submit_my_application
    when_i_visit_my_applications
    when_i_click_to_view_my_application
    when_i_click_to_review_my_application
    when_i_click_to_submit_my_application
  end

  def and_my_application_is_still_unsubmitted
    expect(@application_choice.reload).to be_unsubmitted
  end

  def then_i_can_see_my_application_has_been_successfully_submitted
    expect(page).to have_content 'Application submitted'
  end

  def and_i_am_redirected_to_the_application_dashboard
    expect(page).to have_content t('page_titles.application_dashboard')
    expect(page).to have_content 'Gorse SCITT'
  end

  def and_i_can_see_i_have_three_choices_left
    expect(page).to have_content 'You can add 3 more applications.'
  end

  def when_my_application_is_rejected
    ApplicationStateChange.new(@application_choice.reload).reject!
  end

  def then_i_am_unable_to_add_any_further_choices
    visit current_path
    expect(page).to have_content 'You cannot submit any more applications this year'
    expect(page).to have_content 'This is because you have a total of 15 applications that have been either:'
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
end

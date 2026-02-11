require 'rails_helper'

RSpec.describe 'Visit provider recruitment performance report page' do
  include DfESignInHelpers

  scenario 'provider report has been generated', time: recruitment_performance_report_season do
    given_a_provider_and_provider_user_exists
    and_a_provider_recruitment_performance_report_has_been_generated
    and_national_recruitment_performance_report_has_been_generated
    and_regional_recruitment_performance_report_has_been_generated
    and_reports_from_a_later_week_were_generated_for_last_year

    and_i_am_signed_in_as_provider_user
    and_i_visit_the_new_provider_recruitment_report_page
    then_i_see_the_report_for_the_current_year
    and_i_can_navigate_to_report_sections

    when_i_set_london_as_my_region
    and_i_can_navigate_to_report_sections(report_region: 'Providers in London')

    when_i_visit_the_new_recruitment_report_page
    when_i_can_navigate_to_report_sections(report_region: 'Providers in London')

    when_i_go_to_set_my_comparison_area
    then_the_london_option_is_ticked
  end

  scenario 'provider report has not been generated', mid_cycle do
    given_a_provider_and_provider_user_exists
    and_i_am_signed_in_as_provider_user
    and_i_visit_the_new_provider_recruitment_report_page
    then_i_see_no_report_message

    when_i_set_london_as_my_region
    then_i_see_no_report_message
  end

private

  def given_a_provider_and_provider_user_exists
    @provider_user = create(:provider_user, :with_dfe_sign_in, email_address: 'email@provider.ac.uk')
    @provider = @provider_user.providers.first
  end

  def and_a_provider_recruitment_performance_report_has_been_generated
    create(:provider_recruitment_performance_report, recruitment_cycle_year: current_year, cycle_week: 31, provider: @provider)
  end

  def and_national_recruitment_performance_report_has_been_generated
    create(:national_recruitment_performance_report, recruitment_cycle_year: current_year, cycle_week: 31)
  end

  def and_regional_recruitment_performance_report_has_been_generated
    create(
      :regional_recruitment_performance_report,
      recruitment_cycle_year: current_year,
      cycle_week: 31,
    )
  end

  def and_reports_from_a_later_week_were_generated_for_last_year
    create(:provider_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 43, provider: @provider)
    create(:national_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 43)
    create(:regional_recruitment_performance_report, recruitment_cycle_year: previous_year, cycle_week: 43)
  end

  def and_i_visit_the_new_provider_recruitment_report_page
    visit provider_interface_reports_provider_recruitment_performance_report_path(@provider)
  end
  alias_method :when_i_visit_the_new_recruitment_report_page, :and_i_visit_the_new_provider_recruitment_report_page

  def then_i_see_the_report_for_the_current_year
    year = current_year
    cycle_name = "#{year - 1} to #{year}"
    expect(page).to have_content('Recruitment performance report')
    description = "This report shows your organisation's cumulative recruitment data from the start of the #{cycle_name} cycle to the date displayed above. It compares your data to the same point in the previous cycle and to your chosen comparison region or England."
    expect(page).to have_content(description)
  end

  def and_i_can_navigate_to_report_sections(report_region: 'All providers')
    expect(page).to have_link(
      'Candidates who have submitted applications',
      href: '#candidates_who_have_submitted_applications',
    )
    expect(page).to have_css(
      'h2',
      text: '1. Candidates who have submitted applications',
      id: 'candidates_who_have_submitted_applications',
    )

    expect(page).to have_link('Candidates that received an offer', href: '#candidates_with_an_offer')
    expect(page).to have_css(
      'h2',
      text: '2. Candidates that received an offer',
      id: 'candidates_with_an_offer',
    )

    expect(page).to have_link('Proportion of candidates with an offer', href: '#proportion_of_candidates_with_an_offer')
    expect(page).to have_css(
      'h2',
      text: '3. Proportion of candidates with an offer',
      id: 'proportion_of_candidates_with_an_offer',
    )

    expect(page).to have_link('Offers accepted', href: '#offers_accepted')
    expect(page).to have_css(
      'h2',
      text: '4. Offers accepted',
      id: 'offers_accepted',
    )

    expect(page).to have_link('Deferrals', href: '#candidate_deferrals')
    expect(page).to have_css(
      'h2',
      text: '5. Deferrals',
      id: 'candidate_deferrals',
    )

    expect(page).to have_link('Candidates rejected', href: '#candidates_rejected')
    expect(page).to have_css(
      'h2',
      text: '6. Candidates rejected',
      id: 'candidates_rejected',
    )

    expect(page).to have_link(
      'Proportion of candidates who have waited more than 30 working days for a response',
      href: '#proportion_with_inactive_applications_table_component',
    )
    expect(page).to have_css(
      'h2',
      text: '7. Proportion of candidates who have waited more than 30 working days for a response',
      id: 'proportion_with_inactive_applications_table_component',
    )

    expect(page).to have_content(report_region)
  end
  alias_method :when_i_can_navigate_to_report_sections, :and_i_can_navigate_to_report_sections

  def then_i_see_no_report_message
    expect(page).to have_content('Recruitment performance report')
    expect(page).to have_content('This report is not ready to view.')
  end

  def and_i_am_signed_in_as_provider_user
    provider_exists_in_dfe_sign_in
    provider_signs_in_using_dfe_sign_in
  end
  alias_method :given_i_am_signed_in_as_provider_user, :and_i_am_signed_in_as_provider_user

  def then_i_am_redirected_to_reports_page
    expect(page).to have_current_path provider_interface_reports_path
  end

  def when_i_set_london_as_my_region
    click_on 'Set your comparison area'
    choose 'London'
    click_on 'Update comparison are'
  end

  def when_i_go_to_set_my_comparison_area
    click_on 'Set your comparison area'
  end

  def then_the_london_option_is_ticked
    expect(page).to have_checked_field('London')
  end
end

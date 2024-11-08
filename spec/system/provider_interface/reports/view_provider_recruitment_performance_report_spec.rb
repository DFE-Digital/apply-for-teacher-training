require 'rails_helper'

RSpec.describe 'Visit provider recruitment performance report page' do
  include DfESignInHelpers

  scenario 'provider report has been generated', time: mid_cycle(2024) do
    given_a_provider_and_provider_user_exists
    and_a_provider_recruitment_performance_report_has_been_generated
    and_national_recruitment_performance_report_has_been_generated
    and_i_am_signed_in_as_provider_user
    and_i_visit_the_provider_recruitment_report_page
    then_i_see_the_report
    and_i_can_navigate_to_report_sections
  end

  scenario 'provider report has not been generated', mid_cycle(2024) do
    given_a_provider_and_provider_user_exists
    and_i_am_signed_in_as_provider_user
    and_i_visit_the_provider_recruitment_report_page
    then_i_see_no_report_message
  end

private

  def given_a_provider_and_provider_user_exists
    @provider_user = create(:provider_user, :with_dfe_sign_in, email_address: 'email@provider.ac.uk')
    @provider = @provider_user.providers.first
  end

  def and_a_provider_recruitment_performance_report_has_been_generated
    create(:provider_recruitment_performance_report, provider: @provider)
  end

  def and_national_recruitment_performance_report_has_been_generated
    create(:national_recruitment_performance_report)
  end

  def and_i_visit_the_provider_recruitment_report_page
    visit provider_interface_reports_provider_recruitment_performance_report_path(provider_id: @provider.id)
  end

  def then_i_see_the_report
    expect(page).to have_content('Recruitment performance weekly report 2023 to 2024')
    expect(page).to have_content('This report shows your organisation’s initial teacher training (ITT) recruitment performance so far this recruitment cycle, starting on 3 October 2023.')
  end

  def and_i_can_navigate_to_report_sections
    expect(page).to have_link('About this data', href: '#about_this_data')
    expect(page).to have_css(
      'h2',
      text: '1. About this data',
      id: 'about_this_data',
    )

    expect(page).to have_link(
      'Candidates who have submitted applications',
      href: '#candidates_who_have_submitted_applications',
    )
    expect(page).to have_css(
      'h2',
      text: '2. Candidates who have submitted applications',
      id: 'candidates_who_have_submitted_applications',
    )

    expect(page).to have_link('Candidates with an offer', href: '#candidates_with_an_offer')
    expect(page).to have_css(
      'h2',
      text: '3. Candidates with an offer',
      id: 'candidates_with_an_offer',
    )

    expect(page).to have_link('Proportion of candidates with an offer', href: '#proportion_of_candidates_with_an_offer')
    expect(page).to have_css(
      'h2',
      text: '4. Proportion of candidates with an offer',
      id: 'proportion_of_candidates_with_an_offer',
    )

    expect(page).to have_link('Offers accepted', href: '#offers_accepted')
    expect(page).to have_css(
      'h2',
      text: '5. Offers accepted',
      id: 'offers_accepted',
    )

    expect(page).to have_link('Deferrals', href: '#candidate_deferrals')
    expect(page).to have_css(
      'h2',
      text: '6. Deferrals',
      id: 'candidate_deferrals',
    )

    expect(page).to have_link('Candidates rejected', href: '#candidates_rejected')
    expect(page).to have_css(
      'h2',
      text: '7. Candidates rejected',
      id: 'candidates_rejected',
    )

    expect(page).to have_link(
      'Proportion of candidates who have waited more than 30 days for a response',
      href: '#proportion_of_candidates_who_have_waited_30_days_or_more_for_a_response',
    )
    expect(page).to have_css(
      'h2',
      text: '8. Proportion of candidates who have waited more than 30 days for a response',
      id: 'proportion_of_candidates_who_have_waited_30_days_or_more_for_a_response',
    )
  end

  def then_i_see_no_report_message
    year_range = RecruitmentCycle.cycle_name(CycleTimetable.current_year)
    expect(page).to have_content("Recruitment performance weekly report #{year_range}")
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
end

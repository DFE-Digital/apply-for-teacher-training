require 'rails_helper'

RSpec.describe SupportInterface::ReasonsForRejectionSearchBreadcrumbComponent do
  include Rails.application.routes.url_helpers

  def render_result(
    search_attribute = :quality_of_application_y_n,
    search_value = 'Yes',
    recruitment_cycle_year = RecruitmentCycle.current_year
  )
    @rendered_result ||= render_inline(
      described_class.new(
        search_attribute: search_attribute,
        search_value: search_value,
        recruitment_cycle_year: recruitment_cycle_year,
      ),
    )
  end

  context 'for a top-level reason' do
    before do
      render_result
    end

    it 'renders the correct title' do
      expect(@rendered_result.text).to include('Quality of application')
    end
  end

  context 'for a sub-reason' do
    before do
      render_result(:qualifications_which_qualifications, :no_degree)
    end

    it 'renders the correct title' do
      expect(@rendered_result.text).to include('No degree')
    end

    it 'renders the link back to the dashboard' do
      dashboard_path = support_interface_reasons_for_rejection_dashboard_path(year: RecruitmentCycle.current_year)

      expect(@rendered_result.css("a[href='#{dashboard_path}']")).to be_present
    end

    it 'renders the link back to qualifications' do
      subreason_path = support_interface_reasons_for_rejection_application_choices_path(
        'structured_rejection_reasons[qualifications_y_n]' => 'Yes',
        'recruitment_cycle_year' => RecruitmentCycle.current_year,
      )

      expect(@rendered_result.css("a[href='#{subreason_path}']")).to be_present
    end
  end

  context 'for a previous recruitment cycle' do
    before do
      render_result(:qualifications_which_qualifications, :no_degree, RecruitmentCycle.previous_year)
    end

    it 'renders the link back to the dashboard including the correct year param' do
      dashboard_path = support_interface_reasons_for_rejection_dashboard_path(year: RecruitmentCycle.previous_year)

      expect(@rendered_result.css("a[href='#{dashboard_path}']")).to be_present
    end

    it 'renders the link back to qualifications including the correct recruitment cycle year' do
      subreason_path = support_interface_reasons_for_rejection_application_choices_path(
        'structured_rejection_reasons[qualifications_y_n]' => 'Yes',
        'recruitment_cycle_year' => RecruitmentCycle.previous_year,
      )

      expect(@rendered_result.css("a[href='#{subreason_path}']")).to be_present
    end
  end
end

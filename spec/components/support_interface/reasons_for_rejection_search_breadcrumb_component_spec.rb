require 'rails_helper'

RSpec.describe SupportInterface::ReasonsForRejectionSearchBreadcrumbComponent do
  include Rails.application.routes.url_helpers

  def render_result(
    search_attribute = :id,
    search_value = 'qualifications'
  )
    @rendered_result ||= render_inline(
      described_class.new(
        search_attribute:,
        search_value:,
        recruitment_cycle_year: current_year,
      ),
    )
  end

  context 'for a top-level reason' do
    before do
      render_result
    end

    it 'renders the correct title' do
      expect(@rendered_result.text).to include('Qualifications')
    end
  end

  context 'for a sub-reason' do
    before do
      render_result(:communication_and_scheduling, :communication_and_scheduling_other)
    end

    it 'renders the correct title' do
      expect(@rendered_result.text).to include('Communication And Scheduling Other')
    end

    it 'renders the link back to the dashboard' do
      dashboard_path = support_interface_reasons_for_rejection_dashboard_path(year: current_year)

      expect(@rendered_result.css("a[href='#{dashboard_path}']")).to be_present
    end

    it 'renders the link back to communication' do
      reason_path = support_interface_reasons_for_rejection_application_choices_path(
        'structured_rejection_reasons[id]' => 'communication_and_scheduling',
        'recruitment_cycle_year' => current_year,
      )

      expect(@rendered_result.css("a[href='#{reason_path}']")).to be_present
    end
  end
end

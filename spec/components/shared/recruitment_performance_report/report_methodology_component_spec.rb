require 'rails_helper'

RSpec.describe RecruitmentPerformanceReport::ReportMethodologyComponent do
  let(:provider_report) {
    Publications::ProviderRecruitmentPerformanceReportPresenter.new(
      create(
        :provider_recruitment_performance_report,
        recruitment_cycle_year:,
      ),
    )
  }
  let(:recruitment_cycle_year) { 2026 }

  context 'current_cycle report' do
    describe 'renders the component' do
      subject(:rendered_component) do
        render_inline(
          described_class.new(
            provider_report:,
            comparison_link: "<a href='test.co.uk'</a>",
            region: ReportSharedEnums.all_of_england_key,
          ),
        )
      end

      it 'shows content for current cycle' do
        expect(rendered_component).to have_text(
          "This report shows your organisation's cumulative recruitment data from the start of the 2025 to 2026 cycle to the date displayed above. It compares your data to the same point in the previous cycle and to your chosen comparison region or England.",
        )
        expect(rendered_component).to have_text(
          'Candidates who withdrew or deferred applications after submitting them are included in the figures.',
        )
        expect(rendered_component).to have_text(
          'This report is updated every Monday.',
        )
        expect(rendered_component).to have_text(
          'The 2025 to 2026 recruitment cycle started 30 September 2025 and ends on 28 September 2026.',
        )
        expect(rendered_component).to have_text(
          'Report updates',
        )
        expect(rendered_component).to have_text(
          'This report updates weekly on a Monday, starting from 12 January 2026. You can only view data from the most recent week.',
        )
        expect(rendered_component).to have_text(
          'the same week in the previous recruitment cycle 2024 to 2025',
        )
      end

      it 'does not show content for previous cycle' do
        expect(rendered_component).to have_no_text(
          'The recruitment performance reports for the 2025 to 2026 recruitment cycle will be available from 12 January 2026.',
        )
      end
    end
  end

  context 'previous_cycle report' do
    let(:recruitment_cycle_year) { 2025 }

    describe 'renders the component' do
      subject(:rendered_component) do
        render_inline(
          described_class.new(
            provider_report:,
            comparison_link: "<a href='test.co.uk'</a>",
            region: ReportSharedEnums.all_of_england_key,
          ),
        )
      end

      it 'shows content for previous cycle' do
        expect(rendered_component).to have_text(
          "This report shows your organisation's cumulative recruitment data from the start of the 2024 to 2025 cycle to the date displayed above. It compares your data to the same point in the previous cycle and to your chosen comparison region or England.",
        )
        expect(rendered_component).to have_text(
          'Candidates who withdrew or deferred applications after submitting them are included in the figures.',
        )
        expect(rendered_component).to have_text(
          'The recruitment performance reports for the 2025 to 2026 recruitment cycle will be available from 12 January 2026.',
        )
        expect(rendered_component).to have_text(
          'The 2024 to 2025 recruitment cycle started 1 October 2024 and ends on 29 September 2025.',
        )
        expect(rendered_component).to have_text(
          'the same week in the previous recruitment cycle 2023 to 2024',
        )
      end

      it 'does not show content for current cycle' do
        expect(rendered_component).to have_no_text(
          'This report is updated every Monday.',
        )
        expect(rendered_component).to have_no_text(
          'Report updates',
        )
        expect(rendered_component).to have_no_text(
          'This report updates weekly on a Monday, starting from 12 January 2026. You can only view data from the most recent week.',
        )
      end
    end
  end
end

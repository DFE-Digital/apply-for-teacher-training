require 'rails_helper'

RSpec.describe SupportInterface::SubReasonsForRejectionTableComponent do
  subject(:component) do
    described_class.new(
      reason: 'candidate_behaviour_y_n',
      sub_reasons: { 'didnt_attend_interview' => ReasonsForRejectionCountQuery::Result.new(3, 2, {}) },
      total_all_time: 100,
      total_this_month: 20,
      total_for_reason_all_time: 25,
      total_for_reason_this_month: 15,
    )
  end

  describe '#sub_reason_percentage_of_reason' do
    it 'returns a formatted percentage of occurances of the subreason for a reason' do
      expect(component.sub_reason_percentage_of_reason('didnt_attend_interview')).to eq('12%')
    end

    it 'returns a formatted percentage of occurances of the subreason for a reason for the current month' do
      expect(component.sub_reason_percentage_of_reason('didnt_attend_interview', :this_month)).to eq('13.33%')
    end
  end

  describe '#sub_reason_percentage' do
    it 'returns a formatted percentage of occurances of the subreason for all rejections' do
      expect(component.sub_reason_percentage('didnt_attend_interview')).to eq('3%')
    end

    it 'returns a formatted percentage of occurances of the subreason for rejections this month' do
      expect(component.sub_reason_percentage('didnt_attend_interview', :this_month)).to eq('10%')
    end
  end

  describe '#sub_reason_count' do
    it 'returns the occurance count for the sub reason' do
      expect(component.sub_reason_count('didnt_attend_interview')).to eq(3)
    end

    it 'returns the occurance count for the sub reason for this month' do
      expect(component.sub_reason_count('didnt_attend_interview', :this_month)).to eq(2)
    end
  end

  describe 'rendering for current recruitment cycle' do
    subject(:rendered_component) do
      render_inline(
        described_class.new(
          reason: 'candidate_behaviour_y_n',
          sub_reasons: { 'didnt_attend_interview' => ReasonsForRejectionCountQuery::Result.new(3, 2, {}) },
          total_all_time: 100,
          total_this_month: 20,
          total_for_reason_all_time: 25,
          total_for_reason_this_month: 15,
        ),
      )
    end

    it 'shows all time and current month percentages and totals' do
      travel_temporarily_to(RecruitmentCycleTimetable.current_year, 9, 1) do
        table_headings = rendered_component.css('thead th')
        expect(table_headings.size).to eq(5)
        expect(table_headings[0].text.strip).to eq('Reason')
        expect(table_headings[1].text.strip).to eq('Percentage of all rejections')
        expect(table_headings[2].text.strip).to eq('Percentage of all rejections within this category')
        expect(table_headings[3].text.strip).to eq('Percentage of all rejections in September')
        expect(table_headings[4].text.strip).to eq('Percentage of all rejections in September within this category')

        table_cells = rendered_component.css('tbody td')
        expect(rendered_component.css('tbody th').text.strip).to eq('Didnt attend interview')
        expect(table_cells.size).to eq(4)
        expect(table_cells[0].text.strip).to start_with('3%')
        expect(table_cells[1].text.strip).to start_with('12%')
        expect(table_cells[2].text.strip).to start_with('10%')
        expect(table_cells[3].text.strip).to start_with('13.33%')
      end
    end
  end

  describe 'rendering for a past recruitment cycle' do
    subject(:rendered_component) do
      render_inline(
        described_class.new(
          reason: 'candidate_behaviour_y_n',
          sub_reasons: { 'didnt_attend_interview' => ReasonsForRejectionCountQuery::Result.new(3, 2, {}) },
          total_all_time: 100,
          total_this_month: 20,
          total_for_reason_all_time: 25,
          total_for_reason_this_month: 15,
          recruitment_cycle_year: RecruitmentCycleTimetable.previous_year,
        ),
      )
    end

    it 'only shows all time percentages and totals' do
      table_headings = rendered_component.css('thead th')
      expect(table_headings.size).to eq(3)
      expect(table_headings[0].text.strip).to eq('Reason')
      expect(table_headings[1].text.strip).to eq('Percentage of all rejections')
      expect(table_headings[2].text.strip).to eq('Percentage of all rejections within this category')

      table_cells = rendered_component.css('tbody td')
      expect(rendered_component.css('tbody th').text.strip).to eq('Didnt attend interview')
      expect(table_cells.size).to eq(2)
      expect(table_cells[0].text.strip).to start_with('3%')
      expect(table_cells[1].text.strip).to start_with('12%')
    end
  end
end

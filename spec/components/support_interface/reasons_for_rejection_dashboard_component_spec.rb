require 'rails_helper'

RSpec.describe SupportInterface::ReasonsForRejectionDashboardComponent do
  def result(all_time_count = 0, this_month_count = 0, subreasons = nil)
    ReasonsForRejectionCountQuery::Result.new(all_time_count, this_month_count, subreasons)
  end

  def heading_text(section)
    section.css('.govuk-heading-m').text.strip
  end

  def summary_text(section)
    section.css('.app-card--light-blue').text.split("\n").compact_blank.map(&:strip)
  end

  def details_text(section, row_index)
    section.css('tr')[row_index].text.split("\n").compact_blank.map(&:strip)
  end

  let(:rejection_reasons) do
    ActiveSupport::HashWithIndifferentAccess.new({
      communication_and_scheduling: result(3, 1, {
        'did_not_reply' => result(1, 0),
        'did_not_attend_interview' => result(2, 1),
        'communication_and_scheduling_other' => result,
        'could_not_arrange_interview' => result,
      }),
      course_full: result(4, 2, {}),
      other: result,
      personal_statement: result(4, 1, {
        'quality_of_writing' => result(1, 1),
        'personal_statement_other' => result(3, 0),
      }),
      qualifications: result(7, 4, {
        'unsuitable_degree' => result(1, 1),
        'qualifications_other' => result(1, 1),
        'no_maths_gcse' => result(1, 1),
        'no_english_gcse' => result(1, 1),
        'no_degree' => result(1, 0),
        'unverified_qualifications' => result(2, 0),
      }),
      safeguarding: result(1, 1, {}),
      teaching_knowledge: result(6, 3, {
        'subject_knowledge' => result(1, 1),
        'teaching_knowledge_other' => result(1, 1),
        'teaching_role_knowledge' => result(1, 1),
        'teaching_demonstration' => result(1, 1),
        'teaching_method_knowledge' => result(1, 0),
        'safeguarding_knowledge' => result(1, 0),
      }),
      visa_sponsorship: result(2, 0),
    })
  end

  subject(:component) do
    described_class.new(rejection_reasons, 23, 14)
  end

  describe 'rendered component' do
    let(:rendered_component) { render_inline(component) }

    it 'renders table headings' do
      travel_temporarily_to(RecruitmentCycleTimetable.current_year, 9, 1) do
        header_row = rendered_component.css('.govuk-table__row').first
        header_row_text = header_row.text.split("\n").compact_blank.map(&:strip)
        expect(header_row_text[0]).to eq('Reason')
        expect(header_row_text[1]).to eq('Percentage of all rejections')
        expect(header_row_text[2]).to eq('Percentage of all rejections within this category')
        expect(header_row_text[3]).to eq('Percentage of all rejections in September')
        expect(header_row_text[4]).to eq('Percentage of all rejections in September within this category')
      end
    end

    it 'renders detailed top level section' do
      section = rendered_component.css('.app-section')[1]
      expect(heading_text(section)).to eq('Course full')
      expect(summary_text(section)).to eq(['17.39%', '4 of 23 rejections included this category'])
    end

    it 'renders qualifications section' do
      section = rendered_component.css('.app-section')[4]
      expect(heading_text(section)).to eq('Qualifications')
      expect(summary_text(section)).to eq(['30.43%', '7 of 23 rejections included this category'])
      expect(details_text(section, 1)).to eq(['Unsuitable degree', '4.35%', '1 of 23', '14.29%', '1 of 7', '7.14%', '1 of 14', '25%', '1 of 4'])
      expect(details_text(section, 2)).to eq(['Qualifications other', '4.35%', '1 of 23', '14.29%', '1 of 7', '7.14%', '1 of 14', '25%', '1 of 4'])
      expect(details_text(section, 3)).to eq(['No maths gcse', '4.35%', '1 of 23', '14.29%', '1 of 7', '7.14%', '1 of 14', '25%', '1 of 4'])
      expect(details_text(section, 4)).to eq(['No english gcse', '4.35%', '1 of 23', '14.29%', '1 of 7', '7.14%', '1 of 14', '25%', '1 of 4'])
      expect(details_text(section, 5)).to eq(['No degree', '4.35%', '1 of 23', '14.29%', '1 of 7', '0%', '0 of 14', '0%', '0 of 4'])
      expect(details_text(section, 6)).to eq(['Unverified qualifications', '8.7%', '2 of 23', '28.57%', '2 of 7', '0%', '0 of 14', '0%', '0 of 4'])
    end

    it 'renders teaching knowledge section' do
      section = rendered_component.css('.app-section')[6]
      expect(heading_text(section)).to eq('Teaching knowledge')
      expect(summary_text(section)).to eq(['26.09%', '6 of 23 rejections included this category'])
    end

    it 'renders visa section' do
      section = rendered_component.css('.app-section')[-1]
      expect(heading_text(section)).to eq('Visa sponsorship')
      expect(summary_text(section)).to eq(['8.7%', '2 of 23 rejections included this category'])
    end
  end

  describe '.recruitment_cycle_context' do
    it 'formats a string for the current recruitment cycle' do
      timetable = RecruitmentCycleTimetable.current_timetable
      expected = "#{timetable.cycle_range_name_with_current_indicator} (starts #{timetable.recruitment_cycle_year})"
      expect(described_class.recruitment_cycle_context(timetable.recruitment_cycle_year)).to eq(expected)
    end

    it 'formats a string for a previous recruitment cycle' do
      timetable = RecruitmentCycleTimetable.previous_timetable
      expected = "#{timetable.cycle_range_name} (starts #{timetable.recruitment_cycle_year})"
      expect(described_class.recruitment_cycle_context(timetable.recruitment_cycle_year)).to eq(expected)
    end
  end
end

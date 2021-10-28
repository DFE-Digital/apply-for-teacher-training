require 'rails_helper'

RSpec.describe SupportInterface::ReasonsForRejectionDashboardComponent do
  def result(all_time_count = 0, this_month_count = 0, subreasons = nil)
    ReasonsForRejectionCountQuery::Result.new(all_time_count, this_month_count, subreasons)
  end

  def heading_text(section)
    section.css('.govuk-heading-m').text.strip
  end

  def summary_text(section)
    section.css('.app-card--light-blue').text.split("\n").reject(&:blank?).map(&:strip)
  end

  def details_text(section, row_index)
    section.css('tr')[row_index].text.split("\n").reject(&:blank?).map(&:strip)
  end

  let(:rejection_reasons) do
    ActiveSupport::HashWithIndifferentAccess.new({
      candidate_behaviour_y_n: result(3, 1, {
        'didnt_reply_to_interview_offer' => result(1, 0),
        'didnt_attend_interview' => result(2, 1),
        'other' => result,
      }),
      qualifications_y_n: result(4, 2, {
        'no_maths_gcse' => result,
        'no_english_gcse' => result(2, 1),
        'no_science_gcse' => result(1, 1),
        'no_degree' => result(1, 0),
        'other' => result,
      }),
      quality_of_application_y_n: result,
      honesty_and_professionalism_y_n: result,
      safeguarding_y_n: result(1, 1, {
        'candidate_disclosed_information' => result,
        'vetting_disclosed_information' => result(1, 1),
        'other' => result,
      }),
      cannot_sponsor_visa_y_n: result(2, 0),
      course_full_y_n: result(1, 1),
      offered_on_another_course_y_n: result,
      performance_at_interview_y_n: result,
      other_advice_or_feedback_y_n: result,
    })
  end

  subject(:component) do
    described_class.new(rejection_reasons, 12, 9)
  end

  describe 'rendered component' do
    let(:rendered_component) { render_inline(component) }

    it 'renders table headings' do
      Timecop.freeze(RecruitmentCycle.current_year, 9, 1) do
        header_row = rendered_component.css('.govuk-table__row').first
        header_row_text = header_row.text.split("\n").reject(&:blank?).map(&:strip)
        expect(header_row_text[0]).to eq('Reason')
        expect(header_row_text[1]).to eq('Percentage of all rejections')
        expect(header_row_text[2]).to eq('Percentage of all rejections within this category')
        expect(header_row_text[3]).to eq('Percentage of all rejections in September')
        expect(header_row_text[4]).to eq('Percentage of all rejections in September within this category')
      end
    end

    it 'renders detailed candidate behaviour section' do
      section = rendered_component.css('.app-section')[0]
      expect(heading_text(section)).to eq('Candidate behaviour')
      expect(summary_text(section)).to eq(['25%', '3 of 12 rejections included this category'])
      expect(details_text(section, 1)).to eq(['Didn’t reply to our interview offer', '8.33%', '1 of 12', '33.33%', '1 of 3', '0%', '0 of 9', '0%', '0 of 1'])
      expect(details_text(section, 2)).to eq(['Didn’t attend interview', '16.67%', '2 of 12', '66.67%', '2 of 3', '11.11%', '1 of 9', '100%', '1 of 1'])
    end

    it 'renders quality of application section' do
      section = rendered_component.css('.app-section')[1]
      expect(heading_text(section)).to eq('Quality of application')
      expect(summary_text(section)).to eq(['0%', '0 of 12 rejections included this category'])
    end

    it 'renders qualifications section' do
      section = rendered_component.css('.app-section')[2]
      expect(heading_text(section)).to eq('Qualifications')
      expect(summary_text(section)).to eq(['33.33%', '4 of 12 rejections included this category'])
      expect(details_text(section, 1)).to eq(['No Maths GCSE grade 4 (C) or above, or valid equivalent', '0%', '0 of 12', '0%', '0 of 4', '0%', '0 of 9', '0%', '0 of 2'])
      expect(details_text(section, 2)).to eq(['No English GCSE grade 4 (C) or above, or valid equivalent', '16.67%', '2 of 12', '50%', '2 of 4', '11.11%', '1 of 9', '50%', '1 of 2'])
      expect(details_text(section, 3)).to eq(['No Science GCSE grade 4 (C) or above, or valid equivalent (for primary applicants)', '8.33%', '1 of 12', '25%', '1 of 4', '11.11%', '1 of 9', '50%', '1 of 2'])
    end

    it 'renders interview section' do
      section = rendered_component.css('.app-section')[3]
      expect(heading_text(section)).to eq('Performance at interview')
      expect(summary_text(section)).to eq(['0%', '0 of 12 rejections included this category'])
    end

    it 'renders course full section' do
      section = rendered_component.css('.app-section')[4]
      expect(heading_text(section)).to eq('Course full')
      expect(summary_text(section)).to eq(['8.33%', '1 of 12 rejections included this category'])
    end

    it 'renders alternative course section' do
      section = rendered_component.css('.app-section')[5]
      expect(heading_text(section)).to eq('Offered on another course')
      expect(summary_text(section)).to eq(['0%', '0 of 12 rejections included this category'])
    end

    it 'renders honesty and professionalism section' do
      section = rendered_component.css('.app-section')[6]
      expect(heading_text(section)).to eq('Honesty and professionalism')
      expect(summary_text(section)).to eq(['0%', '0 of 12 rejections included this category'])
    end

    it 'renders safeguarding section' do
      section = rendered_component.css('.app-section')[7]
      expect(heading_text(section)).to eq('Safeguarding concerns')
      expect(summary_text(section)).to eq(['8.33%', '1 of 12 rejections included this category'])
      expect(details_text(section, 2)).to eq(['Information revealed by our vetting process makes the candidate unsuitable to work with children', '8.33%', '1 of 12', '100%', '1 of 1', '11.11%', '1 of 9', '100%', '1 of 1'])
    end

    it 'renders visa section' do
      section = rendered_component.css('.app-section')[8]
      expect(heading_text(section)).to eq('Cannot sponsor visa')
      expect(summary_text(section)).to eq(['16.67%', '2 of 12 rejections included this category'])
    end

    it 'renders other advice section' do
      section = rendered_component.css('.app-section')[9]
      expect(heading_text(section)).to eq('Additional advice or feedback')
      expect(summary_text(section)).to eq(['0%', '0 of 12 application choices'])
    end
  end
end

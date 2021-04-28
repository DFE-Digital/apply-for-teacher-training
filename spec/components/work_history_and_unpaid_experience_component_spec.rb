require 'rails_helper'

RSpec.describe WorkHistoryAndUnpaidExperienceComponent do
  let(:application_form) { instance_double(ApplicationForm, submitted_at: 2.months.ago) }

  before do
    FeatureFlag.activate(:restructured_work_history)
  end

  context 'with an empty history' do
    it 'renders nothing' do
      allow(application_form).to receive(:application_work_experiences).and_return([])
      allow(application_form).to receive(:application_work_history_breaks).and_return([])
      allow(application_form).to receive(:application_volunteering_experiences).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to eq ''
    end
  end

  context 'with full work experience including unpaid experience' do
    it 'renders all experience' do
      breaks = [
        build(:application_work_history_break,
              start_date: 8.years.ago,
              end_date: 6.years.ago,
              reason: 'Raising my kids'),
      ]
      volunteering_xperiences = [
        build(:application_volunteering_experience,
              role: 'Designer',
              working_pattern: 'Part time',
              details: 'Designing things for a charity',
              start_date: 7.years.ago,
              end_date: nil),
      ]
      experiences = [
        build(:application_work_experience,
              start_date: 6.years.ago,
              end_date: 2.years.ago,
              role: 'Sheep herder',
              commitment: 'full_time',
              working_pattern: '',
              details: 'Livestock management'),
        build(:application_work_experience,
              start_date: 2.months.ago,
              end_date: nil,
              role: 'Pig herder',
              commitment: 'part_time',
              working_pattern: '',
              details: 'Livestock management'),
      ]
      allow(application_form).to receive(:application_work_experiences).and_return(experiences)
      allow(application_form).to receive(:application_work_history_breaks).and_return(breaks)
      allow(application_form).to receive(:application_volunteering_experiences).and_return(volunteering_xperiences)

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to include 'Break (2 years)'
      expect(rendered.text).to include 'Raising my kids'
      expect(rendered.text).to include "#{7.years.ago.to_s(:month_and_year)} - Present"
      expect(rendered.text).to include 'Designer - Part time (unpaid)'
      expect(rendered.text).to include 'Designing things for a charity'
      expect(rendered.text).to include "#{6.years.ago.to_s(:month_and_year)} - #{2.years.ago.to_s(:month_and_year)}"
      expect(rendered.text).to include 'Sheep herder - Full time'
      expect(rendered.text).to include 'Unexplained break (1 year and 10 months)'
      expect(rendered.text).to include "#{2.months.ago.to_s(:month_and_year)} - Present"
      expect(rendered.text).to include 'Pig herder - Part time'
    end
  end
end

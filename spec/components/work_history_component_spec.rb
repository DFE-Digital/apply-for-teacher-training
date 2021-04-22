require 'rails_helper'

RSpec.describe WorkHistoryComponent do
  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  let(:application_form) { instance_double(ApplicationForm, submitted_at: 2.months.ago) }

  context 'with an empty history' do
    it 'renders nothing' do
      allow(application_form).to receive(:application_work_experiences).and_return([])
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to eq ''
    end
  end

  context 'with work experiences' do
    it 'renders work experience details' do
      experiences = [
        build(
          :application_work_experience,
          start_date: 6.years.ago,
          end_date: 3.months.ago,
          role: 'Sheep herder',
          commitment: 'full_time',
          working_pattern: '',
          organisation: 'Bobs Farm',
          details: 'Livestock management',
          working_with_children: false,
        ),
        build(
          :application_work_experience,
          start_date: 3.months.ago,
          end_date: nil,
          role: 'Pig herder',
          commitment: 'part_time',
          working_pattern: '',
          organisation: 'Alices Farm',
          details: 'Livestock management',
          working_with_children: false,
        ),
      ]
      allow(application_form).to receive(:application_work_experiences).and_return(experiences)
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to include "#{6.years.ago.to_s(:month_and_year)} - #{3.months.ago.to_s(:month_and_year)}"
      expect(rendered.text).to include 'Sheep herder - Full time'
      expect(rendered.text).to include "#{3.months.ago.to_s(:month_and_year)} - Present"
      expect(rendered.text).to include 'Pig herder - Part time'
      expect(rendered.text).not_to include 'Worked with children'

      expect(rendered.text).not_to include 'Unexplained'
    end
  end

  context 'with work experiences working with children' do
    it 'renders work experience details and worked with children flag' do
      experiences = [
        build(
          :application_work_experience,
          start_date: 6.years.ago,
          end_date: nil,
          role: 'Nursery manager',
          commitment: 'part_time',
          working_pattern: '',
          organisation: 'Bobs Farm',
          details: 'I run the staff nursery',
          working_with_children: true,
        ),
      ]
      allow(application_form).to receive(:application_work_experiences).and_return(experiences)
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to include "#{6.years.ago.to_s(:month_and_year)} - Present"
      expect(rendered.text).to include 'Nursery manager - Part time'
      expect(rendered.text).to include 'Worked with children'
    end
  end

  context 'with work experiences with relevant skills' do
    it 'renders work experience details and relevant skills flag' do
      experiences = [
        build(
          :application_work_experience,
          start_date: 6.years.ago,
          end_date: nil,
          role: 'Nursery manager',
          commitment: 'part_time',
          working_pattern: '',
          organisation: 'Bobs Farm',
          details: 'I run the staff nursery',
          relevant_skills: true,
          working_with_children: true,
        ),
      ]
      allow(application_form).to receive(:application_work_experiences).and_return(experiences)
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to include "#{6.years.ago.to_s(:month_and_year)} - Present"
      expect(rendered.text).to include 'Nursery manager - Part time'
      expect(rendered.text).to include 'This role used skills relevant to teaching'
      expect(rendered.text).not_to include 'Worked with children'
    end
  end

  context 'with work experiences and unexplained work break' do
    it 'renders work experience details and unexplained break' do
      experiences = [
        build(
          :application_work_experience,
          start_date: 6.years.ago,
          end_date: 2.years.ago,
          role: 'Sheep herder',
          commitment: 'full_time',
          working_pattern: '',
          organisation: 'Bobs Farm',
          details: 'Livestock management',
        ),
        build(
          :application_work_experience,
          start_date: 2.months.ago,
          end_date: nil,
          role: 'Pig herder',
          commitment: 'part_time',
          working_pattern: '',
          organisation: 'Alices Farm',
          details: 'Livestock management',
        ),
      ]
      allow(application_form).to receive(:application_work_experiences).and_return(experiences)
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to include "#{6.years.ago.to_s(:month_and_year)} - #{2.years.ago.to_s(:month_and_year)}"
      expect(rendered.text).to include 'Sheep herder - Full time'
      expect(rendered.text).to include 'Unexplained break (1 year and 10 months)'
      expect(rendered.text).to include "#{2.months.ago.to_s(:month_and_year)} - Present"
      expect(rendered.text).to include 'Pig herder - Part time'
    end
  end

  context 'with work experiences and explained work break' do
    it 'renders work experience details and explained break' do
      breaks = [
        build(
          :application_work_history_break,
          start_date: 26.months.ago,
          end_date: 4.months.ago,
          reason: 'I found pig farming very stressful and needed to take time off work',
        ),
      ]
      experiences = [
        build(
          :application_work_experience,
          start_date: 6.years.ago,
          end_date: 26.months.ago,
          role: 'Sheep herder',
          commitment: 'full_time',
          working_pattern: '',
          organisation: 'Bobs Farm',
          details: 'Livestock management',
        ),
        build(
          :application_work_experience,
          start_date: 3.months.ago,
          end_date: nil,
          role: 'Pig herder',
          commitment: 'part_time',
          working_pattern: '',
          organisation: 'Alices Farm',
          details: 'Livestock management',
        ),
      ]
      allow(application_form).to receive(:application_work_experiences).and_return(experiences)
      allow(application_form).to receive(:application_work_history_breaks).and_return(breaks)

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to include "#{6.years.ago.to_s(:month_and_year)} - #{26.months.ago.to_s(:month_and_year)}"
      expect(rendered.text).to include 'Sheep herder - Full time'
      expect(rendered.text).to include 'Break (1 year and 10 months)'
      expect(rendered.text).to include 'I found pig farming very stressful and needed to take time off work'
      expect(rendered.text).to include "#{3.months.ago.to_s(:month_and_year)} - Present"
      expect(rendered.text).to include 'Pig herder - Part time'
    end
  end
end

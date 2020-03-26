require 'rails_helper'

RSpec.describe ProviderInterface::WorkHistoryComponent do
  around do |example|
    Timecop.freeze(Time.zone.local(2020, 4, 1)) do
      example.run
    end
  end

  context 'with an empty history' do
    it 'renders nothing' do
      application_form = instance_double(ApplicationForm, submitted_at: Time.zone.local(2020, 2, 1))
      allow(application_form).to receive(:application_work_experiences).and_return([])
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to eq ''
    end
  end

  context 'with work experiences' do
    it 'renders work experience details' do
      application_form = instance_double(ApplicationForm, submitted_at: Time.zone.local(2020, 2, 1))
      experiences = [
        build(
          :application_work_experience,
          start_date: Date.new(2014, 10, 1),
          end_date: Date.new(2019, 12, 1),
          role: 'Sheep herder',
          commitment: 'full_time',
          working_pattern: '',
          organisation: 'Bobs Farm',
          details: 'Livestock management',
          working_with_children: false,
        ),
        build(
          :application_work_experience,
          start_date: Date.new(2020, 1, 1),
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
      expect(rendered.text).to include 'October 2014 - December 2019'
      expect(rendered.text).to include 'Sheep herder - Full-time'
      expect(rendered.text).to include 'January 2020 - Present'
      expect(rendered.text).to include 'Pig herder - Part-time'
      expect(rendered.text).not_to include 'Worked with children'

      expect(rendered.text).not_to include 'Unexplained'
    end
  end

  context 'with work experiences working with children' do
    it 'renders work experience details and worked with children flag' do
      application_form = instance_double(ApplicationForm, submitted_at: Time.zone.local(2020, 2, 1))
      experiences = [
        build(
          :application_work_experience,
          start_date: Date.new(2014, 10, 1),
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
      expect(rendered.text).to include 'October 2014 - Present'
      expect(rendered.text).to include 'Nursery manager - Part-time'
      expect(rendered.text).to include 'Worked with children'
    end
  end

  context 'with work experiences and unexplained work break' do
    it 'renders work experience details and unexplained break' do
      application_form = instance_double(ApplicationForm, submitted_at: Time.zone.local(2020, 2, 1))
      experiences = [
        build(
          :application_work_experience,
          start_date: Date.new(2014, 10, 1),
          end_date: Date.new(2018, 3, 1),
          role: 'Sheep herder',
          commitment: 'full_time',
          working_pattern: '',
          organisation: 'Bobs Farm',
          details: 'Livestock management',
        ),
        build(
          :application_work_experience,
          start_date: Date.new(2020, 1, 1),
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
      expect(rendered.text).to include 'October 2014 - March 2018'
      expect(rendered.text).to include 'Sheep herder - Full-time'
      expect(rendered.text).to include 'Unexplained break (1 year and 10 months)'
      expect(rendered.text).to include 'January 2020 - Present'
      expect(rendered.text).to include 'Pig herder - Part-time'
    end
  end

  context 'with work experiences and explained work break' do
    it 'renders work experience details and explained break' do
      application_form = instance_double(ApplicationForm, submitted_at: Time.zone.local(2020, 2, 1))
      breaks = [
        build(
          :application_work_history_break,
          start_date: Date.new(2018, 2, 1),
          end_date: Date.new(2019, 12, 1),
          reason: 'I found pig farming very stressful and needed to take time off work',
        ),
      ]
      experiences = [
        build(
          :application_work_experience,
          start_date: Date.new(2014, 10, 1),
          end_date: Date.new(2018, 2, 1),
          role: 'Sheep herder',
          commitment: 'full_time',
          working_pattern: '',
          organisation: 'Bobs Farm',
          details: 'Livestock management',
        ),
        build(
          :application_work_experience,
          start_date: Date.new(2020, 1, 1),
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
      expect(rendered.text).to include 'October 2014 - February 2018'
      expect(rendered.text).to include 'Sheep herder - Full-time'
      expect(rendered.text).to include 'Break (1 year and 10 months)'
      expect(rendered.text).to include 'I found pig farming very stressful and needed to take time off work'
      expect(rendered.text).to include 'January 2020 - Present'
      expect(rendered.text).to include 'Pig herder - Part-time'
    end
  end
end

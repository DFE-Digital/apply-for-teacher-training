require 'rails_helper'

RSpec.describe ProviderInterface::WorkHistoryComponent do
  context 'with an empty history' do
    it 'renders nothing' do
      application_form = instance_double(ApplicationForm)
      allow(application_form).to receive(:application_work_experiences).and_return([])
      allow(application_form).to receive(:application_work_history_breaks).and_return([])

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to eq ''
    end
  end

  context 'with work experiences' do
    it 'renders work experience details' do
      application_form = instance_double(ApplicationForm)
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
      expect(rendered.text).to include 'October 2014 - December 2019'
      expect(rendered.text).to include 'Sheep herder - Full-time'
      expect(rendered.text).to include 'January 2020 - Present'
      expect(rendered.text).to include 'Pig herder - Part-time'

      expect(rendered.text).not_to include 'Unexplained'
    end
  end

  context 'with work experiences and unexplained work break' do
    it 'renders work experience details and unexplained break' do
      application_form = instance_double(ApplicationForm)
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
      application_form = instance_double(ApplicationForm)
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

  context 'with volunteering experiences' do
    it 'renders work, volunteering experience details and explained break' do
      application_form = instance_double(ApplicationForm)
      experiences = [
        build(
          :application_volunteering_experience,
          start_date: Date.new(2020, 1, 1),
          end_date: nil,
          details: 'Childrens entertainer',
          working_with_children: true,
        ),
        build(
          :application_volunteering_experience,
          start_date: Date.new(2018, 3, 1),
          end_date: Date.new(2018, 6, 30),
          details: 'Playgroup helper',
          working_with_children: true,
        ),
      ]
      allow(application_form).to receive(:application_work_experiences).and_return(experiences)

      rendered = render_inline(described_class.new(application_form: application_form))
      expect(rendered.text).to include 'January 2018 - June 2018'
      expect(rendered.text).to include 'Playgroup helper'
      expect(rendered.text).to include 'January 2020 - Present'
      expect(rendered.text).to include 'Childrens entertainer'
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::ReplacementActionComponent do
  let(:application_form) { create(:completed_application_form) }

  context 'when the course_options course is withdrawn' do
    it 'renders component with correct values' do
      course = create(:course, withdrawn: true)
      course_option = create(:course_option, :no_vacancies, course: course)
      application_choice = create(:awaiting_references_application_choice, application_form: application_form, course_option: course_option)
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.text).to include "#{course.name_and_code} is not running anymore."
      expect(result.text).not_to include 'Choose a different location'
      expect(result.text).not_to include "Study #{course_option.alternative_study_mode} instead"
    end
  end

  context 'when the course_option is full and there is no other location or study modes available' do
    it 'renders component with correct values' do
      course = create(:course)
      course_option = create(:course_option, :no_vacancies, :full_time, course: course)
      application_choice = create(:awaiting_references_application_choice, application_form: application_form, course_option: course_option)
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.text).to include "#{course.name_and_code} is now full."
      expect(result.text).not_to include 'Choose a different location'
      expect(result.text).not_to include 'Study part time instead'
    end
  end

  context 'when the course_option is full and there is another location and study mode available' do
    it 'renders component with correct values' do
      course = create(:course)
      course_option = create(:course_option, :no_vacancies, :full_time, course: course)
      application_choice = create(:awaiting_references_application_choice, application_form: application_form, course_option: course_option)
      site = create(:site, provider: course.provider)
      create(:course_option, site: site, course: course)
      create(:course_option, site: course_option.site, course: course_option.course, study_mode: :part_time)
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.text).to include "There are no more #{course_option.study_mode.humanize.downcase} places for #{course.name_and_code} at your choice of location."
      expect(result.text).to include 'Choose a different location'
      expect(result.text).to include 'Study part time instead'
    end
  end

  context 'when the course_option is full and there is another location, but no study mode available' do
    it 'renders component with correct values' do
      course = create(:course)
      course_option = create(:course_option, :no_vacancies, course: course)
      application_choice = create(:awaiting_references_application_choice, application_form: application_form, course_option: course_option)
      site = create(:site, provider: course.provider)
      create(:course_option, site: site, course: course)
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.text).to include "There are no more places at #{course_option.site.name} for #{course.name_and_code}."
      expect(result.text).to include 'Choose a different location'
      expect(result.text).not_to include 'Study part time instead'
    end
  end

  context 'when the course_option there, part time is available and there are no other locations' do
    it 'renders component with correct values' do
      course = create(:course)
      course_option = create(:course_option, :no_vacancies, :full_time, course: course)
      application_choice = create(:awaiting_references_application_choice, application_form: application_form, course_option: course_option)
      create(:course_option, site: course_option.site, course: course_option.course, study_mode: :part_time)
      result = render_inline(described_class.new(course_choice: application_choice))

      expect(result.text).to include "There are no more #{course_option.study_mode.humanize.downcase} places for #{course.name_and_code}."
      expect(result.text).not_to include 'Choose a different location'
      expect(result.text).to include 'Study part time instead'
    end
  end
end

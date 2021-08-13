require 'rails_helper'

RSpec.describe ProviderInterface::WorkHistoryAndUnpaidExperienceComponent, type: :component do
  let(:application_form) do
    instance_double(ApplicationForm,
                    submitted_at: 2.months.ago,
                    full_time_education?: full_time_education,
                    application_work_experiences: work_experiences,
                    application_volunteering_experiences: volunteering_experiences,
                    application_work_history_breaks: breaks)
  end

  let(:work_experiences) do
    [build(:application_work_experience,
           start_date: 6.years.ago,
           end_date: 2.years.ago,
           role: 'Sheep herder',
           commitment: 'full_time',
           details: 'Livestock management'),
     build(:application_work_experience,
           start_date: 2.months.ago,
           end_date: nil,
           role: 'Pig herder',
           commitment: 'part_time',
           details: 'Livestock management')]
  end

  let(:volunteering_experiences) do
    [build(:application_volunteering_experience,
           role: 'Designer',
           working_pattern: 'Part time',
           details: 'Designing things for a charity',
           start_date: 7.years.ago,
           end_date: nil)]
  end
  let(:breaks) { [] }
  let(:full_time_education) { false }

  before do
    FeatureFlag.activate(:restructured_work_history)
  end

  context 'with full work experience including unpaid experience' do
    let(:breaks) do
      [build(:application_work_history_break,
             start_date: 8.years.ago,
             end_date: 6.years.ago,
             reason: 'Raising my kids')]
    end

    it 'renders all experience' do
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

  context 'in full time education with unpaid experience' do
    subject! { render_inline(described_class.new(application_form: application_form)) }

    let(:work_experiences) { [] }
    let(:full_time_education) { true }

    it 'renders the correct details' do
      expect(page).to have_css('dl', class: 'govuk-summary-list') do |summary|
        expect(summary).to have_text('No, I have always been in full time education')
        expect(summary).to have_text('Yes')
      end

      expect(page).to have_css('h3#work-history-subheader', class: 'govuk-heading-m') do |subheader|
        expect(subheader).to have_text('Details of unpaid experience')
      end

      expect(page).to have_css('section', class: 'app-section') do |section|
        expect(section).to have_text 'Designer - Part time (unpaid)'
        expect(section).to have_text 'Designing things for a charity'
        expect(section).to have_text "#{7.years.ago.to_s(:month_and_year)} - Present"
      end
    end
  end

  context 'with both work history and unpaid experience' do
    subject! { render_inline(described_class.new(application_form: application_form)) }

    it 'renders the correct details' do
      expect(page).to have_css('dl', class: 'govuk-summary-list') do |summary|
        expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'Yes')
        expect(summary).not_to have_css('dd', class: 'govuk-summary-list__value', text: 'No')
      end

      expect(page).not_to have_css('h3#work-history-subheader', class: 'govuk-heading-m')

      expect(page).to have_css('section', class: 'app-section') do |section|
        expect(section).to have_text 'Livestock management'
        expect(section).to have_text 'Pig herder'
        expect(section).to have_text "#{6.years.ago.to_s(:month_and_year)} - #{2.years.ago.to_s(:month_and_year)}"

        expect(section).to have_text 'Livestock management'
        expect(section).to have_text 'Sheep herder'
        expect(section).to have_text "#{2.months.ago.to_s(:month_and_year)} - Present"
      end

      expect(page).to have_css('section', class: 'app-section') do |section|
        expect(section).to have_text 'Designer - Part time (unpaid)'
        expect(section).to have_text 'Designing things for a charity'
        expect(section).to have_text "#{7.years.ago.to_s(:month_and_year)} - Present"
      end
    end
  end

  context 'with only work history' do
    subject! { render_inline(described_class.new(application_form: application_form)) }

    let(:volunteering_experiences) { [] }

    it 'renders the correct details' do
      expect(page).to have_css('dl', class: 'govuk-summary-list') do |summary|
        expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'Yes')
        expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'No')
      end

      expect(page).to have_css('h3#work-history-subheader', class: 'govuk-heading-m') do |subheader|
        expect(subheader).to have_text('Details of work history')
      end

      expect(page).to have_css('section', class: 'app-section') do |section|
        expect(section).to have_text 'Livestock management'
        expect(section).to have_text 'Pig herder'
        expect(section).to have_text "#{6.years.ago.to_s(:month_and_year)} - #{2.years.ago.to_s(:month_and_year)}"

        expect(section).to have_text 'Livestock management'
        expect(section).to have_text 'Sheep herder'
        expect(section).to have_text "#{2.months.ago.to_s(:month_and_year)} - Present"
      end
    end

    context 'with no work history or unpaid experience' do
      subject! { render_inline(described_class.new(application_form: application_form)) }

      let(:volunteering_experiences) { [] }
      let(:work_experiences) { [] }

      it 'renders the correct details' do
        expect(page).to have_css('dl', class: 'govuk-summary-list') do |summary|
          expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'No')
          expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'No')
        end
      end
    end
  end
end

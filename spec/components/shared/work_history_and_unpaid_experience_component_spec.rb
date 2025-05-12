require 'rails_helper'

RSpec.describe WorkHistoryAndUnpaidExperienceComponent, type: :component do
  let(:application_form) do
    instance_double(ApplicationForm,
                    submitted_at: 2.months.ago,
                    full_time_education?: full_time_education,
                    application_work_experiences: work_experiences,
                    application_volunteering_experiences: volunteering_experiences,
                    application_work_history_breaks: breaks,
                    editable?: false)
  end

  let(:work_experiences) do
    [build(:application_work_experience,
           start_date: 6.years.ago,
           start_date_unknown: false,
           end_date: 2.years.ago,
           end_date_unknown: false,
           role: 'Sheep herder',
           commitment: 'full_time',
           details: 'Livestock management'),
     build(:application_work_experience,
           start_date: 2.months.ago,
           start_date_unknown: false,
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

  context 'with full work experience including unpaid experience' do
    let(:breaks) do
      [build(:application_work_history_break,
             start_date: 8.years.ago,
             end_date: 6.years.ago,
             reason: 'Raising my kids')]
    end

    it 'renders all experience' do
      rendered = render_inline(described_class.new(application_form:))

      expect(rendered.text).to include 'Break (2 years)'
      expect(rendered.text).to include 'Raising my kids'
      expect(rendered.text).to include "#{7.years.ago.to_fs(:month_and_year)} - Present"
      expect(rendered.text).to include 'Designer - Part time (unpaid)'
      expect(rendered.text).to include 'Designing things for a charity'
      expect(rendered.text).to include "#{6.years.ago.to_fs(:month_and_year)} - #{2.years.ago.to_fs(:month_and_year)}"
      expect(rendered.text).to include 'Sheep herder - Full time'
      expect(rendered.text).to include 'Unexplained break (1 year and 10 months)'
      expect(rendered.text).to include "#{2.months.ago.to_fs(:month_and_year)} - Present"
      expect(rendered.text).to include 'Pig herder - Part time'
    end
  end

  context 'in full time education with unpaid experience' do
    subject! { render_inline(described_class.new(application_form:)) }

    let(:work_experiences) { [] }
    let(:full_time_education) { true }

    it 'renders the correct details' do
      expect(page).to have_css('dl', class: 'govuk-summary-list') do |summary|
        expect(summary).to have_text('No, I have always been in full time education')
        expect(summary).to have_text('Yes')
      end

      expect(page).to have_css('h4#work-history-subheader', class: 'govuk-heading-s') do |subheader|
        expect(subheader).to have_text('Details of unpaid experience')
      end

      expect(page).to have_css('section', class: 'app-section') do |section|
        expect(section).to have_text 'Designer - Part time (unpaid)'
        expect(section).to have_text 'Designing things for a charity'
        expect(section).to have_text "#{7.years.ago.to_fs(:month_and_year)} - Present"
      end
    end
  end

  context 'with both work history and unpaid experience' do
    subject! { render_inline(described_class.new(application_form:)) }

    it 'renders the correct details' do
      expect(page).to have_css('dl', class: 'govuk-summary-list') do |summary|
        expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'Yes')
        expect(summary).to have_no_css('dd', class: 'govuk-summary-list__value', text: 'No')
      end

      expect(page).to have_css('h4#work-history-subheader', class: 'govuk-heading-s') do |subheader|
        expect(subheader).to have_text('Details of work history and unpaid experience')
      end

      expect(page).to have_css('section', class: 'app-section') do |section|
        expect(section).to have_text 'Livestock management'
        expect(section).to have_text 'Pig herder'
        expect(section).to have_text "#{6.years.ago.to_fs(:month_and_year)} - #{2.years.ago.to_fs(:month_and_year)}"

        expect(section).to have_text 'Livestock management'
        expect(section).to have_text 'Sheep herder'
        expect(section).to have_text "#{2.months.ago.to_fs(:month_and_year)} - Present"
      end

      expect(page).to have_css('section', class: 'app-section') do |section|
        expect(section).to have_text 'Designer - Part time (unpaid)'
        expect(section).to have_text 'Designing things for a charity'
        expect(section).to have_text "#{7.years.ago.to_fs(:month_and_year)} - Present"
      end
    end
  end

  context 'without work history details' do
    subject! { render_inline(described_class.new(application_form:, details: false)) }

    it 'does not include the details of work experience' do
      expect(page).to have_no_text('Details of work history and unpaid experience')
    end
  end

  context 'with only work history' do
    subject! { render_inline(described_class.new(application_form:)) }

    let(:volunteering_experiences) { [] }

    it 'renders the correct details' do
      expect(page).to have_css('dl', class: 'govuk-summary-list') do |summary|
        expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'Yes')
        expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'No')
      end

      expect(page).to have_css('h4#work-history-subheader', class: 'govuk-heading-s') do |subheader|
        expect(subheader).to have_text('Details of work history')
      end

      expect(page).to have_css('section', class: 'app-section') do |section|
        expect(section).to have_text 'Livestock management'
        expect(section).to have_text 'Pig herder'
        expect(section).to have_text "#{6.years.ago.to_fs(:month_and_year)} - #{2.years.ago.to_fs(:month_and_year)}"

        expect(section).to have_text 'Livestock management'
        expect(section).to have_text 'Sheep herder'
        expect(section).to have_text "#{2.months.ago.to_fs(:month_and_year)} - Present"
      end
    end

    context 'with no work history or unpaid experience' do
      subject! { render_inline(described_class.new(application_form:)) }

      let(:volunteering_experiences) { [] }
      let(:work_experiences) { [] }

      it 'renders the correct details' do
        expect(page).to have_css('dl', class: 'govuk-summary-list') do |summary|
          expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'No')
          expect(summary).to have_css('dd', class: 'govuk-summary-list__value', text: 'No')
        end
      end
    end

    context 'with unpaid experience that involved working with children' do
      let(:volunteering_experiences) do
        [build(:application_volunteering_experience,
               role: 'TA',
               working_pattern: 'Part time',
               details: 'Supervising classroom',
               working_with_children: true,
               start_date: 7.years.ago,
               end_date: nil)]
      end
      let(:work_experiences) { [] }

      before { allow(volunteering_experiences.first).to receive(:application_form).and_return(application_form) }

      it 'renders all experience' do
        rendered = render_inline(described_class.new(application_form:))

        expect(rendered.text).to include "#{7.years.ago.to_fs(:month_and_year)} - Present"
        expect(rendered.text).to include 'TA - Part time (unpaid)'
        expect(rendered.text).to include 'Supervising classroom'
        expect(rendered.text).to include 'Worked with children'
      end
    end
  end
end

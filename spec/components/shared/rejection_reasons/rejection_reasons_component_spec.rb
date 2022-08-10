require 'rails_helper'

RSpec.describe RejectionReasons::RejectionReasonsComponent do
  describe 'rendered component' do
    let(:provider) { build_stubbed(:provider, name: 'The University of Metal') }
    let(:application_choice) { build_stubbed(:application_choice) }
    let(:rejection_reasons) do
      RejectionReasons.new(
        selected_reasons: [
          { id: 'qualifications', label: 'Qualifications', selected_reasons: [
            { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent.' },
            { id: 'no_english_gcse', label: 'No English GCSE at minimum grade 4 or C, or equivalent.' },
            { id: 'no_science_gcse', label: 'No science GCSE at minimum grade 4 or C, or equivalent.' },
            {
              id: 'unsuitable_degree',
              label: 'Degree does not meet course requirements',
              details: {
                id: 'unsuitable_degree_details',
                label: 'Details',
                text: 'A degree in falconry is no use.',
              },
            },
          ] },
          {
            id: 'references',
            label: 'References',
            details: {
              id: 'references_details',
              label: 'Details',
              text: 'A close family member, suchas your mother, cannot give a reference.',
            },
          },
          { id: 'course_full', label: 'Course full', details: { id: 'course_full_details' } },
          {
            id: 'other',
            label: 'Other',
            details: {
              id: 'other_details',
              label: 'Details',
              text: 'Here are some additional details',
            },
          },
        ],
      )
    end

    before { allow(application_choice).to receive(:provider).and_return(provider) }

    it 'renders rejection reasons as a summary list' do
      result = render_inline(described_class.new(application_choice: application_choice, reasons: rejection_reasons))

      expect(result.css('.govuk-summary-list__key').map(&:text)).to eq([
        'Qualifications',
        'References',
        'Course full',
        'Other',
      ])
      expect(result.css('.govuk-summary-list__value ul li').map { |li| li.text.gsub(/\s+/, ' ').strip }).to eq([
        'No maths GCSE at minimum grade 4 or C, or equivalent.',
        'No English GCSE at minimum grade 4 or C, or equivalent.',
        'No science GCSE at minimum grade 4 or C, or equivalent.',
        'Degree does not meet course requirements: A degree in falconry is no use.',
      ])
      expect(result.css('.govuk-summary-list__value p').map(&:text).map(&:strip)).to eq([
        'Degree does not meet course requirements:',
        'A degree in falconry is no use.',
        'A close family member, suchas your mother, cannot give a reference.',
        'The course is full.',
        'Here are some additional details',
      ])
    end

    it 'renders a link to find for qualifications' do
      provider = build_stubbed(:provider)
      course = build_stubbed(:course)
      allow(application_choice).to receive(:provider).and_return(provider)
      allow(application_choice).to receive(:course).and_return(course)

      result = render_inline(
        described_class.new(
          application_choice: application_choice,
          reasons: rejection_reasons,
          render_link_to_find_when_rejected_on_qualifications: true,
        ),
      )

      expect(result.css('.govuk-summary-list__key').first.text).to eq('Qualifications')
      expect(result.css('.govuk-summary-list__value').first.text).to include('View the course requirements on Find postgraduate teacher training courses')

      expect(result.css('.govuk-link').size).to eq(1)
      link_element = result.css('.govuk-summary-list__value').first.css('.govuk-link').first
      expect(link_element[:href]).to eq("https://www.find-postgraduate-teacher-training.service.gov.uk/course/#{provider.code}/#{course.code}#section-entry")
      expect(link_element.text).to eq('Find postgraduate teacher training courses')
    end

    it 'renders change links' do
      result = render_inline(described_class.new(application_choice: application_choice, reasons: rejection_reasons, editable: true))

      expect(result.css('.govuk-summary-list__actions a').first.text).to eq('Change')
      expect(result.css('.govuk-summary-list__actions a').first['href']).to eq("/provider/applications/#{application_choice.id}/rejections/new")
    end
  end
end

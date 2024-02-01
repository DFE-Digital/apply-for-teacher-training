require 'rails_helper'

RSpec.describe CandidateInterface::RejectionReasons::RejectionReasonsComponent do
  describe 'rendered component' do
    let(:provider) { build_stubbed(:provider, name: 'The University of Metal') }
    let(:application_choice) { build_stubbed(:application_choice, structured_rejection_reasons:) }
    let(:structured_rejection_reasons) do
      { selected_reasons: [
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
      ] }
    end

    before { allow(application_choice).to receive(:provider).and_return(provider) }

    it 'renders rejection reasons as a summary list' do
      result = render_inline(described_class.new(application_choice:))

      expect(result.css('.app-rejection__label').map(&:text)).to eq([
        'Qualifications:',
        'References:',
        'Course full:',
        'Other:',
      ])
      expect(result.css('.app-rejection__body ul li').text).to include(
        'No maths GCSE at minimum grade 4 or C, or equivalent.',
        'No English GCSE at minimum grade 4 or C, or equivalent.',
        'No science GCSE at minimum grade 4 or C, or equivalent.',
      )
      expect(result.css('.app-rejection__body ul li p').map(&:text).map(&:strip)).to eq([
        'Degree does not meet course requirements:',
        'A degree in falconry is no use.',
      ])
      expect(result.css('.app-rejection__body p').text).to include(
        'A close family member, suchas your mother, cannot give a reference.',
        'The course is full.',
        'Here are some additional details',
      )
    end

    it 'renders a link to find for qualifications' do
      provider = build_stubbed(:provider)
      course = build_stubbed(:course)
      allow(application_choice).to receive_messages(course: course)
      allow(course).to receive_messages(provider: provider)

      result = render_inline(
        described_class.new(
          application_choice:,
          render_link_to_find_when_rejected_on_qualifications: true,
        ),
      )

      expect(result.css('.app-rejection__label').first.text).to eq('Qualifications:')
      expect(result.css('.app-rejection').first.css('p').last.text).to include('View the course requirements on Find postgraduate teacher training courses')

      expect(result.css('.govuk-link').size).to eq(1)
      link_element = result.css('.app-rejection').first.css('.govuk-link').first
      expect(link_element[:href]).to eq("#{course.find_url}#section-entry")
      expect(link_element.text).to eq('Find postgraduate teacher training courses')
    end
  end
end

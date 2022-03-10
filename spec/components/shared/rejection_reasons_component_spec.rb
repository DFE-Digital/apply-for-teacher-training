require 'rails_helper'

RSpec.describe RejectionReasonsComponent do
  describe 'rendered component' do
    let(:provider) { build_stubbed(:provider, name: 'The University of Metal') }
    let(:application_choice) { build_stubbed(:application_choice) }
    let(:rejection_reasons) do
      RejectionReasons.new(
        selected_reasons: [
          RejectionReasons::Reason.new(id: 'qualifications', label: 'Qualifications', selected_reasons: [
            RejectionReasons::Reason.new(id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent.'),
            RejectionReasons::Reason.new(id: 'no_english_gcse', label: 'No English GCSE at minimum grade 4 or C, or equivalent.'),
            RejectionReasons::Reason.new(id: 'no_science_gcse', label: 'No science GCSE at minimum grade 4 or C, or equivalent.'),
            RejectionReasons::Reason.new(id: 'unsuitable_degree', label: 'Degree does not meet course requirements',
                                         details: {
                                           id: 'unsuitable_degree_details',
                                           label: 'Details',
                                           text: 'A degree in falconry is no use.',
                                         }),
          ]),
          RejectionReasons::Reason.new(id: 'references', label: 'References',
                                       details: {
                                         id: 'references_details',
                                         label: 'Details',
                                         text: 'A close family member, suchas your mother, cannot give a reference.',
                                       }),
          RejectionReasons::Reason.new(id: 'course_full', label: 'Course full'),
          RejectionReasons::Reason.new(id: 'other', label: 'Other',
                                       details: {
                                         id: 'other_details',
                                         label: 'Details',
                                         text: 'Here are some additional details',
                                       }),
        ],
      )
    end

    before { allow(application_choice).to receive(:provider).and_return(provider) }

    it 'renders rejection reasons as a summary list' do
      result = render_inline(described_class.new(application_choice: application_choice, rejection_reasons: rejection_reasons))

      expect(result.css('.govuk-summary-list__key').map(&:text)).to eq([
        'Qualifications',
        'References',
        'Course full',
        'Other',
      ])
      expect(result.css('.govuk-summary-list__value ul li').map(&:text).map(&:strip)).to eq([
        'No maths GCSE at minimum grade 4 or C, or equivalent.',
        'No English GCSE at minimum grade 4 or C, or equivalent.',
        'No science GCSE at minimum grade 4 or C, or equivalent.',
        'A degree in falconry is no use.',
      ])
      expect(result.css('.govuk-summary-list__value p').map(&:text).map(&:strip)).to eq([
        'A degree in falconry is no use.',
        'A close family member, suchas your mother, cannot give a reference.',
        'The course is full.',
        'Here are some additional details',
      ])
    end

    it 'renders change links' do
      result = render_inline(described_class.new(application_choice: application_choice, rejection_reasons: rejection_reasons, editable: true))

      expect(result.css('.govuk-summary-list__actions a').first.text).to eq('Change')
      expect(result.css('.govuk-summary-list__actions a').first['href']).to eq("/provider/applications/#{application_choice.id}/rejections/new")
    end
  end
end

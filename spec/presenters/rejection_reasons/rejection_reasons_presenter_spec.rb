require 'rails_helper'

RSpec.describe RejectionReasons::RejectionReasonsPresenter do
  describe '#rejection_reasons' do
    let(:reasons) { {} }
    let(:application_choice) do
      build_stubbed(
        :application_choice,
        structured_rejection_reasons: reasons,
        rejection_reasons_type: 'rejection_reasons',
      )
    end

    let(:rejected_application_choice) { described_class.new(application_choice) }

    describe 'when there are no rejection reasons' do
      it 'returns an empty hash' do
        expect(rejected_application_choice.rejection_reasons).to eq({})
      end
    end

    describe 'reasons with nested reasons' do
      let(:reasons) do
        {
          selected_reasons: [
            { id: 'qualifications', label: 'Qualifications', selected_reasons: [
              { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
              { id: 'qualifications_other', label: 'Other', details: { id: 'qualifications_other_details', text: 'Some text' } },
            ] },
          ],
        }
      end

      it 'adds nested reasons as values keyed by top level reason label' do
        expect(rejected_application_choice.rejection_reasons).to eq({
          'Qualifications' => [
            'No maths GCSE at minimum grade 4 or C, or equivalent.',
            'Other:',
            'Some text',
          ],
        })
      end
    end

    describe 'reasons with details' do
      let(:reasons) do
        {
          selected_reasons: [
            { id: 'other', label: 'Other', details: { id: 'other_details', text: 'Some text?' } },
          ],
        }
      end

      it 'returns the details text keyed with the top level reason label' do
        expect(rejected_application_choice.rejection_reasons).to eq({ 'Other' => ['Some text?'] })
      end
    end

    describe 'reasons with no details or nested reasons' do
      let(:reasons) do
        {
          selected_reasons: [{ id: 'course_full', label: 'Course full' }],
        }
      end

      it 'returns i18n translation keyed with the top level reason label' do
        expect(rejected_application_choice.rejection_reasons).to eq({ 'Course full' => ['The course is full.'] })
      end
    end
  end
end

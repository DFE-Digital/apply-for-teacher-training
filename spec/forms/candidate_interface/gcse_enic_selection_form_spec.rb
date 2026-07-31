require 'rails_helper'

RSpec.describe CandidateInterface::GcseEnicSelectionForm do
  describe 'validations' do
    let(:form) { subject }

    it { is_expected.to validate_presence_of(:enic_reason) }

    describe '#build_from_qualification' do
      it 'creates an object based on the provided ApplicationQualification' do
        qualification = ApplicationQualification.new(
          enic_reason: 'obtained',
        )

        enic_selection_form = described_class.build_from_qualification(
          qualification,
        )

        expect(enic_selection_form.enic_reason).to eq qualification.enic_reason
      end
    end

    describe '#save' do
      it 'returns false if not valid' do
        enic_selection_form = described_class.new

        expect(
          enic_selection_form.save(ApplicationQualification.new),
        ).to be(false)
      end

      it 'updates the provided ApplicationQualification if valid' do
        qualification = build(:gcse_qualification)

        enic_selection_form = described_class.new(
          enic_reason: 'obtained',
        )

        expect(
          enic_selection_form.save(qualification),
        ).to be(true)

        expect(qualification.enic_reason).to eq('obtained')
      end

      it 'clears ENIC fields when enic_reason is not obtained' do
        qualification = build(
          :gcse_qualification,
          enic_reference: '12345',
          comparable_uk_qualification: 'GCSE (grades A*-C / 9-4)',
        )

        enic_selection_form = described_class.new(
          enic_reason: 'waiting',
        )

        enic_selection_form.save(qualification)

        expect(qualification.enic_reason).to eq('waiting')
        expect(qualification.enic_reference).to be_nil
        expect(qualification.comparable_uk_qualification).to be_nil
      end
    end
  end
end

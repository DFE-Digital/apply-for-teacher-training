require 'rails_helper'

RSpec.describe CandidateInterface::GcseEnicForm do
  describe 'validations' do
    let(:form) { subject }

    let(:qualification_data) do
      {
        enic_reference: '12345',
        comparable_uk_qualification: 'GCSE (grades A*-C / 9-4)',
      }
    end

    it { is_expected.to validate_presence_of(:enic_reference) }
    it { is_expected.to validate_presence_of(:comparable_uk_qualification) }

    describe '#build_from_qualification' do
      it 'creates an object based on the provided ApplicationQualification' do
        qualification = ApplicationQualification.new(qualification_data)
        enic_form = described_class.build_from_qualification(
          qualification,
        )

        expect(enic_form.enic_reference).to eq qualification.enic_reference
        expect(enic_form.comparable_uk_qualification).to eq qualification.comparable_uk_qualification
      end
    end

    describe '#save' do
      let(:form_data) do
        {
          enic_reference: '12345',
          comparable_uk_qualification: 'GCSE (grades A*-C / 9-4)',
        }
      end

      it 'returns false if not valid' do
        enic_form = described_class.new

        expect(enic_form.save(ApplicationQualification.new)).to be(false)
      end

      it 'updates the provided ApplicationQualification if valid' do
        qualification = build(:gcse_qualification)
        enic_form = described_class.new(form_data)

        expect(enic_form.save(qualification)).to be(true)
        expect(qualification.enic_reference).to eq form_data[:enic_reference]
        expect(qualification.comparable_uk_qualification).to eq form_data[:comparable_uk_qualification]
      end
    end
  end
end

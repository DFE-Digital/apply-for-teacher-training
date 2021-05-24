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

    it { is_expected.to validate_presence_of(:have_enic_reference) }

    context 'validates enic_reference if they have chosen that they have one' do
      before { allow(form).to receive(:chose_to_provide_enic_reference?).and_return(true) }

      it { is_expected.to validate_presence_of(:enic_reference) }
    end

    context 'validates comparable_uk_qualification if they have chosen to provide a ENIC reference' do
      before { allow(form).to receive(:chose_to_provide_enic_reference?).and_return(true) }

      it { is_expected.to validate_presence_of(:comparable_uk_qualification) }
    end

    describe '#build_from_qualification' do
      it 'creates an object based on the provided ApplicationQualification' do
        qualification = ApplicationQualification.new(qualification_data)
        enic_form = CandidateInterface::GcseEnicForm.build_from_qualification(
          qualification,
        )

        expect(enic_form.have_enic_reference).to eq 'Yes'
        expect(enic_form.enic_reference).to eq qualification.enic_reference
        expect(enic_form.comparable_uk_qualification).to eq qualification.comparable_uk_qualification
      end
    end

    describe '#save' do
      let(:form_data) do
        {
          have_enic_reference: 'Yes',
          enic_reference: '12345',
          comparable_uk_qualification: 'GCSE (grades A*-C / 9-4)',
        }
      end

      it 'returns false if not valid' do
        enic_form = CandidateInterface::GcseEnicForm.new

        expect(enic_form.save(ApplicationQualification.new)).to eq(false)
      end

      it 'updates the provided ApplicationQualification if valid' do
        qualification = build(:gcse_qualification)
        enic_form = CandidateInterface::GcseEnicForm.new(form_data)

        expect(enic_form.save(qualification)).to eq(true)
        expect(qualification.enic_reference).to eq form_data[:enic_reference]
        expect(qualification.comparable_uk_qualification).to eq form_data[:comparable_uk_qualification]
      end

      it 'updates enic_reference and comparable_uk_qualification to nil if they choose no' do
        qualification = build(:gcse_qualification)
        enic_form = CandidateInterface::GcseEnicForm.new(
          have_enic_reference: 'No',
          enic_reference: '12345',
          comparable_uk_qualification: 'GCSE (grades A*-C / 9-4)',
        )

        expect(enic_form.save(qualification)).to eq(true)
        expect(qualification.enic_reference).to eq nil
        expect(qualification.comparable_uk_qualification).to eq nil
      end
    end
  end
end

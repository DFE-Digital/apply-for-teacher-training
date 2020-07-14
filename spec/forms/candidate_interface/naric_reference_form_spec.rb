require 'rails_helper'

RSpec.describe CandidateInterface::NaricReferenceForm do
  describe 'validations' do
    let(:form) { subject }

    let(:qualification_data) do
      {
        naric_reference: '12345',
        comparable_uk_qualification: 'GCSE (grades A*-C / 9-4)',
      }
    end

    it { is_expected.to validate_presence_of(:naric_reference_choice) }

    context 'validates naric_reference if they have chosen that they have one' do
      before { allow(form).to receive(:chose_to_provide_naric_reference?).and_return(true) }

      it { is_expected.to validate_presence_of(:naric_reference) }
    end

    context 'validates comparable_uk_qualification if they have chosen to provide a naric reference' do
      before { allow(form).to receive(:chose_to_provide_naric_reference?).and_return(true) }

      it { is_expected.to validate_presence_of(:comparable_uk_qualification) }
    end

    describe '#build_from_qualification' do
      it 'creates an object based on the provided ApplicationQualification' do
        qualification = ApplicationQualification.new(qualification_data)
        naric_reference_form = CandidateInterface::NaricReferenceForm.build_from_qualification(
          qualification,
        )

        expect(naric_reference_form.naric_reference_choice).to eq 'Yes'
        expect(naric_reference_form.naric_reference).to eq qualification.naric_reference
        expect(naric_reference_form.comparable_uk_qualification).to eq qualification.comparable_uk_qualification
      end
    end

    describe '#save' do
      let(:form_data) do
        {
          naric_reference: '12345',
          comparable_uk_qualification: 'GCSE (grades A*-C / 9-4)',
          naric_reference_choice: 'Yes',
        }
      end

      it 'returns false if not valid' do
        naric_reference_form = CandidateInterface::NaricReferenceForm.new

        expect(naric_reference_form.save(ApplicationQualification.new)).to eq(false)
      end

      it 'updates the provided ApplicationQualification if valid' do
        qualification = create(:gcse_qualification)
        naric_reference_form = CandidateInterface::NaricReferenceForm.new(form_data)

        expect(naric_reference_form.save(qualification)).to eq(true)
        expect(qualification.naric_reference).to eq form_data[:naric_reference]
        expect(qualification.comparable_uk_qualification).to eq form_data[:comparable_uk_qualification]
      end
    end
  end
end

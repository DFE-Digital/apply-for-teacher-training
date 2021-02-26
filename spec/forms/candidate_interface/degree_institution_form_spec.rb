require 'rails_helper'

RSpec.describe CandidateInterface::DegreeInstitutionForm do
  describe '#save' do
    context 'when missing institution' do
      it 'returns false and has errors' do
        form = described_class.new

        expect(form.save).to eq false
        expect(form.errors.full_messages).to eq ['Institution name Enter the institution where you studied']
      end
    end

    context 'when institution matches a HESA entry' do
      it 'updates the degree institution and HESA code' do
        form = described_class.new(
          degree: create(:degree_qualification), institution_name: 'Harper Adams University',
        )

        form.save

        expect(form.degree.institution_name).to eq 'Harper Adams University'
        expect(form.degree.institution_hesa_code).to eq 18
      end
    end

    context 'when institution does not match a HESA entry' do
      it 'updates the degree institution' do
        form = described_class.new(
          degree: create(:degree_qualification), institution_name: 'Non-HESA institution',
        )

        form.save

        expect(form.degree.institution_name).to eq 'Non-HESA institution'
        expect(form.degree.institution_hesa_code).to eq nil
      end
    end

    context 'when non-UK degree is selected' do
      it 'updates the instituation_name and country' do
        degree = create(
          :degree_qualification,
          international: true,
          application_form: build(:application_form),
        )
        form = described_class.new(
          degree: degree,
          institution_name: 'University of Pune',
          institution_country: 'IN',
        )
        form.save

        expect(degree.institution_name).to eq 'University of Pune'
        expect(degree.institution_country).to eq 'IN'
        expect(degree.international).to be true
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::DegreeInstitutionForm do
  describe '#institution_name' do
    subject(:form) do
      described_class.new(
        institution_name: 'University of Oxford',
        institution_name_raw: institution_name_raw,
      )
    end

    context 'when institution name raw is present' do
      let(:institution_name_raw) { 'Westminster College' }

      it 'returns raw value' do
        expect(form.institution_name).to eq(institution_name_raw)
      end
    end

    context 'when institution name raw is empty' do
      let(:institution_name_raw) { '' }

      it 'returns raw value' do
        expect(form.institution_name).to eq(institution_name_raw)
      end
    end

    context 'when institution name raw is nil' do
      let(:institution_name_raw) { nil }

      it 'returns original value' do
        expect(form.institution_name).to eq('University of Oxford')
      end
    end
  end

  describe '#save' do
    context 'when missing institution' do
      it 'returns false and has errors' do
        form = described_class.new

        expect(form.save).to be false
        expect(form.errors.full_messages).to eq ['Institution name Enter the institution where you studied']
      end
    end

    context 'when institution matches a HESA entry' do
      let(:form) do
        described_class.new(
          degree: create(:degree_qualification), institution_name: 'Harper Adams University',
        )
      end

      before do
        form.save
      end

      it 'updates the degree institution and HESA code' do
        expect(form.degree.institution_name).to eq 'Harper Adams University'
        expect(form.degree.institution_hesa_code).to eq '18'
      end

      it 'updates the degree institution uuid' do
        expect(form.degree.degree_institution_uuid).to eq('1b369414-75d9-e911-a863-000d3ab0da57')
      end
    end

    context 'when institutions match a synonym' do
      let(:form) do
        described_class.new(
          degree: create(:degree_qualification), institution_name: 'The Royal Central School of Speech and Drama',
        )
      end

      before do
        form.save
      end

      it 'saves the degree institution uuid' do
        expect(form.degree.degree_institution_uuid).to eq 'd90a4e73-a141-e811-80ff-3863bb351d40'
      end
    end

    context 'when institution does not match a HESA entry' do
      let(:form) do
        described_class.new(
          degree: create(:degree_qualification), institution_name: 'Non-HESA institution',
        )
      end

      before do
        form.save
      end

      it 'updates the degree institution' do
        expect(form.degree.institution_name).to eq 'Non-HESA institution'
        expect(form.degree.institution_hesa_code).to be_nil
      end

      it 'saves the degree institution uuid as nil' do
        expect(form.degree.degree_institution_uuid).to be_nil
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

require 'rails_helper'

RSpec.describe CandidateInterface::EnglishProficiencies::TypeForm, type: :model do
  describe 'validations' do
    let(:valid_form) do
      described_class.new(
        type:
      )
    end
    let(:type) { 'ielts' }

    context 'when the type is "ielts"' do
      it 'is valid with valid attributes' do
        expect(valid_form).to be_valid
      end
    end

    context 'when the type is "toefl"' do
      let(:type) { 'toefl' }

      it 'is valid with valid attributes' do
        expect(valid_form).to be_valid
      end
    end

    context 'when the type is "other"' do
      let(:type) { 'other' }

      it 'is valid with valid attributes' do
        expect(valid_form).to be_valid
      end
    end

    context 'when the type is "invalid"' do
      let(:type) { 'invalid' }

      it 'is valid with valid attributes' do
        expect(valid_form).not_to be_valid
      end
    end
  end

  describe '#save' do
    let(:valid_form) do
      described_class.new(
        type:
      )
    end
    let(:type) { 'ielts' }

    context 'when the type is valid' do
      it 'returns true' do
        expect(valid_form.save).to eq(true)
      end
    end

    context 'when the type is valid' do
      let(:type) { 'invalid' }

      it 'returns true' do
        expect(valid_form.save).to eq(false)
      end
    end
  end

  describe '#fill' do
    let(:valid_form) do
      described_class.new(
        type: "ielts",
        english_proficiency:
      )
    end
    let(:english_proficiency) do
      create(
        :english_proficiency,
        :with_ielts_qualification,
        has_qualification: true,
        efl_qualification: create(:ielts_qualification, band_score: '2'),
      )
    end

    context 'when the english proficiency type is "IeltsQualification"' do
      it 'returns "ielts"' do
        expect(valid_form.fill.type).to eq('ielts')
      end
    end

    context 'when the english proficiency type is "ToeflQualification"' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :with_toefl_qualification,
          has_qualification: true,
          efl_qualification: create(:toefl_qualification, total_score: 5),
        )
      end

      it 'returns "toefl"' do
        expect(valid_form.fill.type).to eq('toefl')
      end
    end

    context 'when the english proficiency type is "OtherEflQualification"' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :with_other_efl_qualification,
          has_qualification: true,
        )
      end

      it 'returns "other"' do
        expect(valid_form.fill.type).to eq('other')
      end
    end
  end

  describe '#next_path' do
    let(:form) do
      described_class.new(type:, english_proficiency:)
    end
    let(:english_proficiency) do
      create(
        :english_proficiency,
        :with_ielts_qualification,
        has_qualification: true,
        efl_qualification: create(:ielts_qualification, band_score: '2'),
        )
    end
    let(:type) { 'ielts' }

    context 'the type attribute is "ielts"' do
      it 'returns the path to entering the ielts qualification details' do
        expect(form.next_path).to eq(
          "/candidate/application/english-proficiencies/ielts/#{english_proficiency.id}",
        )
      end
    end

    context 'the type attribute is "toefl"' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :with_toefl_qualification,
          has_qualification: true,
          efl_qualification: create(:toefl_qualification, total_score: 5),
        )
      end
      let(:type) { 'toefl' }

      it 'returns the path to entering the toefl qualification details' do
        expect(form.next_path).to eq(
          "/candidate/application/english-proficiencies/toefl/#{english_proficiency.id}",
        )
      end
    end

    context 'the type attribute is "other"' do
      let(:english_proficiency) do
        create(
          :english_proficiency,
          :with_other_efl_qualification,
          has_qualification: true,
        )
      end
      let(:type) { 'other' }

      it 'returns the path to entering the toefl qualification details' do
        expect(form.next_path).to eq(
          "/candidate/application/english-proficiencies/other/#{english_proficiency.id}",
        )
      end
    end
  end
end

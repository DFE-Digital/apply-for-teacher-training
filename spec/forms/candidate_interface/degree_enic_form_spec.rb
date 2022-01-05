require 'rails_helper'

RSpec.describe CandidateInterface::DegreeEnicForm do
  describe '#save' do
    context 'when `have_enic_reference` is "yes"' do
      it 'returns false if enic_reference and comparable_uk_degree are empty' do
        degree = create(
          :degree_qualification,
          international: true,
          application_form: build(:application_form),
        )

        form = described_class.new(
          degree: degree,
          have_enic_reference: 'yes',
        )

        expect(form.save).to eq false
        expect(form.errors.full_messages).to match_array([
          'Enic reference Enter the UK ENIC reference number',
          'Comparable uk degree Select the comparable UK degree',
        ])
      end

      it 'returns true and saves enic_reference and comparable_uk_degree' do
        degree = create(
          :degree_qualification,
          international: true,
          application_form: build(:application_form),
        )

        form = described_class.new(
          degree: degree,
          have_enic_reference: 'yes',
          enic_reference: '0123456789',
          comparable_uk_degree: 'bachelor_ordinary_degree',
        )

        expect(form.save).to eq true
        expect(degree.reload.enic_reference).to eq '0123456789'
        expect(degree.comparable_uk_degree).to eq 'bachelor_ordinary_degree'
      end
    end

    context 'when `have_enic_reference` is "no"' do
      it 'returns true and updated enic_reference and comparable_uk_degree to nil' do
        degree = create(
          :degree_qualification,
          international: true,
          application_form: build(:application_form),
          enic_reference: '0123456789',
          comparable_uk_degree: 'bachelor_ordinary_degree',
        )

        form = described_class.new(
          degree: degree,
          have_enic_reference: 'no',
          enic_reference: '0123456789',
          comparable_uk_degree: 'bachelor_ordinary_degree',
        )

        expect(form.save).to eq true
        expect(degree.reload.enic_reference).to be_nil
        expect(degree.comparable_uk_degree).to be_nil
      end
    end
  end

  describe 'ENIC reference validations' do
    let(:form) {
      described_class.new(
        degree: degree,
        have_enic_reference: 'yes',
        enic_reference: number_of_characters,
        comparable_uk_degree: 'bachelor_ordinary_degree',
      )
    }

    let(:degree) {
      build(
        :degree_qualification,
        international: true,
        application_form: build(:application_form),
      )
    }

    context 'when enic_reference is more than 100 characters' do
      let(:number_of_characters) { SecureRandom.alphanumeric(101) }

      it 'DegreeForm is invalid' do
        expect(form.save).to eq false
        expect(form.errors.full_messages).to match_array(['Enic reference Your UK ENIC reference number must be 100 characters or fewer'])
      end
    end

    context 'when enic_reference is 100 characters or less' do
      let(:number_of_characters) { SecureRandom.alphanumeric(99) }

      it 'DegreeForm is valid' do
        expect(form.save).to eq true
        expect(degree.reload.enic_reference).to eq(number_of_characters)
      end
    end
  end
end

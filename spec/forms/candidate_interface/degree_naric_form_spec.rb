require 'rails_helper'

RSpec.describe CandidateInterface::DegreeNaricForm do
  describe '#save' do
    context 'when `have_naric_reference` is "yes"' do
      it 'returns false if naric_reference and comparable_uk_degree are empty' do
        degree = create(
          :degree_qualification,
          international: true,
          application_form: build(:application_form),
        )

        form = described_class.new(
          degree: degree,
          have_naric_reference: 'yes',
        )

        expect(form.save).to eq false
        expect(form.errors.full_messages).to match_array([
          'Naric reference Enter the UK NARIC reference number',
          'Comparable uk degree Select the comparable UK degree',
        ])
      end

      it 'returns true and saves naric_reference and comparable_uk_degree' do
        degree = create(
          :degree_qualification,
          international: true,
          application_form: build(:application_form),
        )

        form = described_class.new(
          degree: degree,
          have_naric_reference: 'yes',
          naric_reference: '0123456789',
          comparable_uk_degree: 'bachelor_ordinary_degree',
        )

        expect(form.save).to eq true
        expect(degree.reload.naric_reference).to eq '0123456789'
        expect(degree.comparable_uk_degree).to eq 'bachelor_ordinary_degree'
      end
    end

    context 'when `have_naric_reference` is "no"' do
      it 'returns true and updated naric_reference and comparable_uk_degree to nil' do
        degree = create(
          :degree_qualification,
          international: true,
          application_form: build(:application_form),
          naric_reference: '0123456789',
          comparable_uk_degree: 'bachelor_ordinary_degree',
        )

        form = described_class.new(
          degree: degree,
          have_naric_reference: 'no',
          naric_reference: '0123456789',
          comparable_uk_degree: 'bachelor_ordinary_degree',
        )

        expect(form.save).to eq true
        expect(degree.reload.naric_reference).to be_nil
        expect(degree.comparable_uk_degree).to be_nil
      end
    end
  end
end

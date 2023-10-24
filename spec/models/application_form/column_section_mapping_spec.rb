require 'rails_helper'

RSpec.describe ApplicationForm::ColumnSectionMapping do
  describe '.by_section' do
    subject { described_class.by_section(section_name) }

    context 'with nil argument' do
      let(:section_name) { nil }

      it { is_expected.to eq([]) }
    end

    context 'with one argument' do
      let(:section_name) { 'personal_information' }

      it { is_expected.to eq(%w[date_of_birth first_name last_name]) }
    end

    context 'with one symbol argument' do
      let(:section_name) { :personal_information }

      it { is_expected.to eq(%w[date_of_birth first_name last_name]) }
    end

    context 'with two arguments' do
      let(:section_name) { %w[personal_information disability_disclosure] }

      it 'returns the correct collection of columns' do
        expect(described_class.by_section(*section_name)).to eq(%w[date_of_birth first_name last_name disability_disclosure])
      end
    end

    context 'with two arguments when one does not match' do
      let(:section_name) { %w[personal_information no_entry] }

      it 'returns the correct collection of columns' do
        expect(described_class.by_section(*section_name)).to eq(%w[date_of_birth first_name last_name])
      end
    end
  end

  describe '.by_column' do
    subject { described_class.by_column(column_name) }

    context 'with nil argument' do
      let(:column_name) { nil }

      it { is_expected.to be_nil }
    end

    context 'with one argument' do
      let(:column_name) { 'date_of_birth' }

      it { is_expected.to eq('personal_information') }
    end

    context 'with one symbol argument' do
      let(:column_name) { :date_of_birth }

      it { is_expected.to eq('personal_information') }
    end

    context 'with one argument and it is not present' do
      let(:column_name) { 'no_entry' }

      it { is_expected.to be_nil }
    end

    context 'with two arguments that resolve to the same value' do
      let(:column_names) { %w[date_of_birth first_name] }

      it 'returns the value only once' do
        expect(described_class.by_column(*column_names)).to eq(%w[personal_information])
      end
    end

    context 'with two arguments' do
      let(:column_names) { %w[date_of_birth disability_disclosure] }

      it 'returns the values in an array' do
        expect(described_class.by_column(*column_names)).to eq(%w[personal_information disability_disclosure])
      end
    end

    context 'with two arguments and one is not present' do
      let(:column_names) { %w[date_of_birth no_entry] }

      it 'returns array with the position corresponding to the unmatched as nil' do
        expect(described_class.by_column(*column_names)).to eq(['personal_information', nil])
      end
    end
  end
end

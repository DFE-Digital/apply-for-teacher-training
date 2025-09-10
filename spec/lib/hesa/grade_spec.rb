require 'rails_helper'

RSpec.describe Hesa::Grade do
  describe '.all' do
    it 'returns a list of HESA grade structs' do
      grades = described_class.all

      expect(grades.size).to eq 16
      pass = grades.find { |s| s.hesa_code == '14' }
      expect(pass.hesa_code).to eq '14'
      expect(pass.description).to eq 'Pass'
    end
  end

  describe '.find_by_description' do
    subject(:result) { described_class.find_by_description(description) }

    context 'when search by description' do
      let(:description) { 'Lower second-class honours (2:2)' }

      it 'returns the result' do
        expect(result.description).to eq(description)
      end
    end

    context 'when search by a synonym' do
      let(:description) { 'First class honours' }

      it 'returns the result' do
        expect(result).not_to be_nil
        expect(result.description).to eq('First-class honours')
      end
    end

    context 'when there is no data' do
      let(:description) { 'This does not exist' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end

  describe '.main_grouping' do
    it 'returns undergrad and postgrad grades with the "main" visual grouping' do
      main_grades = described_class.main_grouping

      expect(main_grades.size).to eq 9
      first = main_grades.first
      merit = main_grades.find { |g| g.hesa_code == '13' }
      expect(first.description).to eq 'First-class honours'
      expect(merit.description).to eq 'Merit'
      expect(first.visual_grouping).to eq :main_undergrad
      expect(merit.visual_grouping).to eq :main_postgrad
    end
  end

  describe '.undergrad_grouping_only' do
    it 'returns only undergrad grades with the "main" visual grouping' do
      main_grades = described_class.undergrad_grouping_only

      expect(main_grades.size).to eq 5
      first = main_grades.first
      merit = main_grades.find { |g| g.hesa_code == '13' }
      expect(first.description).to eq 'First-class honours'
      expect(merit).to be_nil
    end
  end

  describe '.other_grouping' do
    it 'returns grades with the "other" visual grouping' do
      other_grades = described_class.other_grouping

      expect(other_grades.size).to eq 7
      unclassified = other_grades.third
      expect(unclassified.description).to eq 'Unclassified'
      expect(unclassified.visual_grouping).to eq :other
    end
  end

  describe '.grouping_for(degree_type_code:)' do
    context 'given a valid HESA degree type code for a bachelors degree' do
      let(:grouping) { described_class.grouping_for(degree_type_code: '051') }

      it 'returns the undergrad grouping only' do
        expect(grouping.size).to eq 5
        expect(grouping.first.visual_grouping).to eq :main_undergrad
        expect(grouping.find { |grade| grade.visual_grouping == :main_postgrad }).to be_nil
      end
    end

    context 'given a valid HESA degree type code for a non-bachelors degree' do
      let(:grouping) { described_class.grouping_for(degree_type_code: 200) }

      it 'returns the entire main grouping' do
        expect(grouping.size).to eq 9
        expect(grouping.first.visual_grouping).to eq :main_undergrad
        expect(grouping.find { |grade| grade.visual_grouping == :main_postgrad }).not_to be_nil
      end
    end

    context 'given an invalid degree type code' do
      let(:grouping) { described_class.grouping_for(degree_type_code: nil) }

      it 'returns the entire main grouping' do
        expect(grouping.size).to eq 9
        expect(grouping.first.visual_grouping).to eq :main_undergrad
        expect(grouping.find { |grade| grade.visual_grouping == :main_postgrad }).not_to be_nil
      end
    end
  end
end

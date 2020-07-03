require 'rails_helper'

RSpec.describe Hesa::Grade do
  describe '.all' do
    it 'returns a list of HESA grade structs' do
      grades = described_class.all

      expect(grades.size).to eq 15
      pass = grades.find { |s| s.hesa_code == 14 }
      expect(pass.hesa_code).to eq 14
      expect(pass.description).to eq 'Pass'
    end
  end

  describe '.main' do
    it 'returns grades with the "main" visual grouping' do
      main_grades = described_class.main

      expect(main_grades.size).to eq 9
      first = main_grades.first
      expect(first.description).to eq 'First class honours'
      expect(first.visual_grouping).to eq :main
    end
  end

  describe '.other' do
    it 'returns grades with the "other" visual grouping' do
      other_grades = described_class.other

      expect(other_grades.size).to eq 6
      unclassified = other_grades.third
      expect(unclassified.description).to eq 'Unclassified'
      expect(unclassified.visual_grouping).to eq :other
    end
  end
end

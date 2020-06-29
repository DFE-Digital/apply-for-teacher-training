require 'rails_helper'

RSpec.describe Hesa::Institution do
  describe '.all' do
    it 'returns a list of HESA institution structs' do
      subjects = described_class.all

      expect(subjects.size).to eq 210
      kings = subjects.find { |s| s.hesa_code == 134 }
      expect(kings.hesa_code).to eq 134
      expect(kings.name).to eq "King's College London"
    end
  end
end

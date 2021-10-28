require 'rails_helper'

RSpec.describe DataAPI::TADSubjectsExport do
  before do
  end

  it_behaves_like 'a data export'

  describe '#data_for_export' do
    it 'works' do
      result = described_class.new.data_for_export

      expect(result).to eq(Hash.new)
    end
  end
end

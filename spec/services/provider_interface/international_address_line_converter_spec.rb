require 'rails_helper'

RSpec.describe ProviderInterface::InternationalAddressLineConverter do
  describe '#convert' do
    let(:raw_data) do
      <<-RAW.strip_heredoc
        1213||
        Saitama Prefecture,
        Koshigaya city,
        Sengendainishi 3-3
        Pakutaun 10-301
        ###
        2234||
        PIPELINE ROAD 1 CLOSE A HOUSE 18 RUMUAGHOLU NKPOLU OBIO AKPOR RIVERS STATE NIGERIA
      RAW
    end

    let(:csv_buffer) { [] }

    before do
      allow(File).to receive(:read).and_return(raw_data)
      allow(CSV).to receive(:open).and_yield(csv_buffer)

      described_class.new.convert('test')
    end

    it 'produces CSV output' do
      expect(csv_buffer.first).to eq(%w[id address_line1 address_line2 address_line3 address_line4])
    end

    it 'converts single lines of addresses to multiple lines' do
      expect(csv_buffer[1]).to eq(['1213', 'saitama prefecture koshigaya city sengendainishi', '3-3 pakutaun'])
    end

    it 'splits long address lines to 50 chars or less' do
      expect(csv_buffer[2]).to eq(['2234', 'rumuagholu nkpolu obio akpor rivers state nigeria', 'house 18 pipeline road 1 close a'])
    end
  end
end

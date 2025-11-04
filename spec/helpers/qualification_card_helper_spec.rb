require 'rails_helper'

RSpec.describe QualificationCardHelper do
  describe '#sub_header_tag' do
    context 'when the header tag is a h1' do
      let(:header_tag) { 'h1' }

      it 'returns h2' do
        expect(helper.sub_header_tag(header_tag:)).to eq('h2')
      end
    end

    context 'when the header tag is a h2' do
      let(:header_tag) { 'h2' }

      it 'returns h3' do
        expect(helper.sub_header_tag(header_tag:)).to eq('h3')
      end
    end

    context 'when the header tag is a h3' do
      let(:header_tag) { 'h3' }

      it 'returns h4' do
        expect(helper.sub_header_tag(header_tag:)).to eq('h4')
      end
    end

    context 'when the header tag is a h4' do
      let(:header_tag) { 'h4' }

      it 'returns h5' do
        expect(helper.sub_header_tag(header_tag:)).to eq('h5')
      end
    end

    context 'when the header tag is not a header' do
      let(:header_tag) { 'p' }

      it 'returns a h1' do
        expect(helper.sub_header_tag(header_tag:)).to eq('h1')
      end
    end
  end
end

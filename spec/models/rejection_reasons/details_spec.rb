require 'rails_helper'

RSpec.describe RejectionReasons::Details do
  describe 'validations' do
    before do
      allow(I18n).to receive(:t).and_return('Invalid!')
    end

    it 'validates presence of text' do
      details = described_class.new(id: 'aaa', text: '')

      expect(details.valid?).to be false
      expect(details.errors.attribute_names).to eq([:aaa])

      details.text = 'yeh'

      expect(details.valid?).to be true
    end

    it 'validates word count of text' do
      words = 'All work and no play makes Jack a dull boy. '
      21.times { words += words }

      details = described_class.new(id: 'aaa', text: words)

      expect(details.valid?).to be false
      expect(details.errors.attribute_names).to eq([:aaa])
    end

    it 'omits validation if details are optional' do
      expect(described_class.new(id: 'aaa', text: '', optional: true)).to be_valid
    end
  end

  describe '#as_json' do
    it 'returns required attributes' do
      instance = described_class.new(id: 'd1', label: 'D1', text: 'Dee one')

      expect(instance.as_json.keys.sort).to eq(%i[id text])
    end
  end
end

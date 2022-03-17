require 'rails_helper'

RSpec.describe RejectionReasons::Reason do
  describe 'initialize' do
    it 'initializes details' do
      instance = described_class.new(
        id: 'aaa',
        label: 'AAA',
        details: { id: 'ddd', label: 'DDD', text: 'DeeDeeDee' },
      )
      expect(instance.details).to be_a(RejectionReasons::Details)
      expect(instance.details.id).to eq('ddd')
      expect(instance.details.label).to eq('DDD')
      expect(instance.details.text).to eq('DeeDeeDee')
    end

    it 'initializes reasons' do
      instance = described_class.new(
        id: 'aaa',
        label: 'AAA',
        reasons: [{ id: 'r1', label: 'R1' }, { id: 'r2', label: 'R2', details: { id: 'd1', label: 'D1' } }],
      )
      expect(instance.reasons.size).to eq(2)
      expect(instance.reasons.map(&:class).uniq).to eq([described_class])
      expect(instance.reasons.first.id).to eq('r1')
      expect(instance.reasons.first.label).to eq('R1')
      expect(instance.reasons.last.id).to eq('r2')
      expect(instance.reasons.last.label).to eq('R2')
      expect(instance.reasons.last.details.id).to eq('d1')
      expect(instance.reasons.last.details.label).to eq('D1')
    end

    it 'initializes selected_reasons' do
      instance = described_class.new(
        id: 'aaa',
        label: 'AAA',
        selected_reasons: [{ id: 'r1', label: 'R1' }, { id: 'r2', label: 'R2', details: { id: 'd1', label: 'D1', text: 'Dee one' } }],
      )
      expect(instance.selected_reasons.size).to eq(2)
      expect(instance.selected_reasons.map(&:class).uniq).to eq([described_class])
      expect(instance.selected_reasons.first.id).to eq('r1')
      expect(instance.selected_reasons.first.label).to eq('R1')
      expect(instance.selected_reasons.last.id).to eq('r2')
      expect(instance.selected_reasons.last.label).to eq('R2')
      expect(instance.selected_reasons.last.details.id).to eq('d1')
      expect(instance.selected_reasons.last.details.label).to eq('D1')
      expect(instance.selected_reasons.last.details.text).to eq('Dee one')
    end
  end

  describe 'validations' do
    before do
      allow(I18n).to receive(:t).and_return('Invalid!')
    end

    it 'validates that a reason has been selected' do
      reason = described_class.new(
        id: 'aaa',
        reasons: [{ id: 'bbb' }],
        selected_reasons: [],
      )
      expect(reason.valid?).to be false
      expect(reason.errors.attribute_names).to eq([:aaa_selected_reasons])

      reason.selected_reasons << described_class.new(id: 'ccc')

      expect(reason.valid?).to be true
    end

    it 'validates details' do
      reason = described_class.new(
        id: 'aaa',
        details: { id: 'bbb', text: nil },
      )
      expect(reason.valid?).to be false
      expect(reason.errors.attribute_names).to eq([:bbb])

      reason.details = RejectionReasons::Details.new(id: 'ccc', text: 'yeh')

      expect(reason.valid?).to be true
    end
  end
end

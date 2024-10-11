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
        reasons_visually_hidden: 'about AAA',
        reasons: [{ id: 'r1', label: 'R1' }, { id: 'r2', label: 'R2', details: { id: 'd1', label: 'D1' } }],
      )
      expect(instance.reasons.size).to eq(2)
      expect(instance.reasons.map(&:class).uniq).to eq([described_class])
      expect(instance.reasons_visually_hidden).to eq('about AAA')
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

  describe 'as_json' do
    it 'contains selected_reasons if present' do
      instance = described_class.new(
        id: 'aaa',
        label: 'AAA',
        reasons: [{ id: 'r1', label: 'R1' }, { id: 'r2', label: 'R2' }],
        selected_reasons: [{ id: 'r1', label: 'R1' }],
      )
      expect(instance.as_json.keys.sort).to eq(%i[id label selected_reasons])
    end

    it 'omits selected_reasons if they are not present' do
      instance = described_class.new(
        id: 'aaa',
        label: 'AAA',
        reasons: [{ id: 'r1', label: 'R1' }, { id: 'r2', label: 'R2' }],
      )
      expect(instance.as_json.keys.sort).to eq(%i[id label])
    end

    it 'contains details if details is present' do
      instance = described_class.new(
        id: 'aaa',
        label: 'AAA',
        details: { id: 'd1', label: 'D1', text: 'Dee One' },
      )
      expect(instance.as_json.keys.sort).to eq(%i[details id label])
    end

    it 'omits details unless details text is present' do
      instance = described_class.new(
        id: 'aaa',
        label: 'AAA',
        details: { id: 'd1', label: 'D1' },
      )
      expect(instance.as_json.keys.sort).to eq(%i[id label])
    end
  end

  describe '#label_text' do
    let(:reason) do
      described_class.new(
        id: label_id,
        label:,
        details: { id: 'ddd', label: 'DDD', text: 'DeeDeeDee' },
      )
    end

    context 'when translation exists' do
      let(:label_id) { 'unsuitable_a_levels' }
      let(:label) { 'Some label from config' }

      it 'returns the translated label' do
        expect(reason.label_text).to eq('A levels do not meet course requirements')
      end
    end

    context 'when translation does not exist' do
      let(:label_id) { 'qualifications' }
      let(:label) { 'Qualifications' }

      it 'returns the fallback label from configuration' do
        expect(reason.label_text).to eq('Qualifications')
      end
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

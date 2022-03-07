require 'rails_helper'

RSpec.describe RejectionReasons do
  let(:test_config) do
    {
      reasons: [
        { id: 'a', label: 'A',
          reasons: [
            { id: 'aa', label: 'AA', details: { id: 'ad', label: 'AD' } },
            { id: 'ab', label: 'AB' },
          ] },
        { id: 'b', label: 'B', details: { id: 'bd', label: 'BD' } },
        { id: 'c', label: 'C' },
      ],
    }
  end

  subject(:instance) { described_class.from_config }

  before do
    described_class.instance_variable_set(:@configuration, nil)
    allow(YAML).to receive(:load_file).with(described_class::CONFIG_PATH).and_return(test_config)
  end

  it 'memoizes configuration' do
    described_class.from_config
    described_class.from_config

    expect(YAML).to have_received(:load_file).with(described_class::CONFIG_PATH).once
  end

  describe '#reasons' do
    it 'builds top level rejection reasons' do
      expect(instance.reasons).to be_a(Array)
      expect(instance.reasons.first).to be_a(RejectionReasons::Reason)
      expect(instance.reasons.map(&:id)).to eq(%w[a b c])
    end

    it 'builds nested reasons' do
      qualifications = instance.reasons.first

      expect(qualifications.reasons).to be_a(Array)
      expect(qualifications.reasons.first).to be_a(RejectionReasons::Reason)
      expect(qualifications.reasons.map(&:id)).to eq(%w[aa ab])
    end

    it 'builds details for reasons' do
      reason = instance.reasons.first
      nested_reason = reason.reasons.first

      expect(nested_reason).to be_a(RejectionReasons::Reason)
      expect(nested_reason.details).to be_a(RejectionReasons::Details)

      reason_with_details = instance.reasons.second

      expect(reason_with_details).to be_a(RejectionReasons::Reason)
      expect(reason_with_details.details).to be_a(RejectionReasons::Details)
    end
  end

  describe '#single_attribute_names' do
    it 'returns an array of all single attribute names' do
      expect(instance.single_attribute_names.sort).to eq(%i[aa ab ad bd])
    end
  end

  describe '#collection_attribute_names' do
    it 'returns an array of all collection attribute names' do
      expect(instance.collection_attribute_names.sort).to eq(%i[a_selected_reasons selected_reasons])
    end
  end

  describe '#attribute_names' do
    it 'returns an array of all attribute names' do
      expect(instance.attribute_names.sort).to eq(%i[a_selected_reasons aa ab ad bd selected_reasons])
    end
  end

  describe 'validations' do
    it 'validates that a reason has been selected' do
      rejection_reasons = described_class.new(
        reasons: [{ id: 'bbb' }],
        selected_reasons: [],
      )
      expect(rejection_reasons.valid?).to be false
      expect(rejection_reasons.errors.attribute_names).to eq([:base])

      rejection_reasons.selected_reasons << RejectionReasons::Reason.new(id: 'bbb')

      expect(rejection_reasons.valid?).to be true
    end
  end

  describe '#inflate' do
    it 'populates reasons and details with values from the model' do
      model_struct = Struct.new(:selected_reasons, :a_selected_reasons, :aa, :ab, :ad, :b, :bd, :c)
      model = model_struct.new(['a'], %w[aa], nil, nil, 'Some details')

      inflated_reasons = described_class.inflate(model)

      selected_reasons = inflated_reasons.selected_reasons
      nested_selected_reasons = selected_reasons.first.selected_reasons

      expect(selected_reasons.first.id).to eq('a')
      expect(nested_selected_reasons.first.id).to eq('aa')
      expect(nested_selected_reasons.first.details.text).to eq('Some details')
    end
  end
end

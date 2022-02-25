require 'rails_helper'

RSpec.describe DfE::ReferenceData::JoinedReferenceList do
  let(:hardcoded_reference_list1) do
    DfE::ReferenceData::HardcodedReferenceList.new(
      {
        '1' => { name: 'Alaric', child: false },
        '2' => { name: 'Sarah', child: false },
      },
    )
  end

  let(:hardcoded_reference_list2) do
    DfE::ReferenceData::HardcodedReferenceList.new(
      {
        '3' => { name: 'Jean', child: true },
        '4' => { name: 'Mary', child: true },
      },
    )
  end

  let(:joined_reference_list) do
    described_class.new([hardcoded_reference_list1, hardcoded_reference_list2])
  end

  # NB: These particular tests also make a potentially fragile assumption that
  # the implementation of some preserves the order of entries, it would be
  # better if we sorted the results by :id or used an order-insensitive array
  # comparator

  it 'returns correct data from low-level methods' do
    expect(joined_reference_list.all).to eq([
      { id: '1', name: 'Alaric', child: false },
      { id: '2', name: 'Sarah', child: false },
      { id: '3', name: 'Jean', child: true },
      { id: '4', name: 'Mary', child: true },
    ])

    expect(joined_reference_list.one('1')).to eq({ id: '1', name: 'Alaric', child: false })
    expect(joined_reference_list.one('3')).to eq({ id: '3', name: 'Jean', child: true })
    expect(joined_reference_list.one('nonexistent')).to eq(nil)
  end
end

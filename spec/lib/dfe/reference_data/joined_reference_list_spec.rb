require 'rails_helper'

RSpec.describe DfE::ReferenceData::JoinedReferenceList do
  hrl1 = DfE::ReferenceData::HardcodedReferenceList.new(
    {
      '1' => { name: 'Alaric', child: false },
      '2' => { name: 'Sarah', child: false }
    }
  )

  hrl2 = DfE::ReferenceData::HardcodedReferenceList.new(
    {
      '3' => { name: 'Jean', child: true },
      '4' => { name: 'Mary', child: true }
    }
  )

  jrl = DfE::ReferenceData::JoinedReferenceList.new([hrl1, hrl2])

  # NB: These particular tests also make a potentially fragile assumption that
  # the implementation of some preserves the order of entries, it would be
  # better if we sorted the results by :id or used an order-insensitive array
  # comparator

  it 'returns correct data from low-level methods' do
    expect(jrl.all).to eq([
                            { id: '1', name: 'Alaric', child: false },
                            { id: '2', name: 'Sarah', child: false },
                            { id: '3', name: 'Jean', child: true },
                            { id: '4', name: 'Mary', child: true }
                          ])

    expect(jrl.one('1')).to eq({ id: '1', name: 'Alaric', child: false })
    expect(jrl.one('3')).to eq({ id: '3', name: 'Jean', child: true })
    expect(jrl.one('nonexistent')).to eq(nil)
  end
end

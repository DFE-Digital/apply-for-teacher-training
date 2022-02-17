require 'rails_helper'

RSpec.describe DfE::ReferenceData::HardcodedReferenceList do
  let(:hardcoded_reference_list) do
    DfE::ReferenceData::HardcodedReferenceList.new(
      {
        '1' => { name: 'Alaric', child: false },
        '2' => { name: 'Sarah', child: false },
        '3' => { name: 'Jean', child: true },
        '4' => { name: 'Mary', child: true }
      }
    )
  end

  context 'when accessing the attributes of each record' do
    let(:records) { hardcoded_reference_list.all }

    it 'returns the values for each attribute' do
      expect(records.first.name).to eq('Alaric')
      expect(records.first.child).to be(false)
    end
  end

  # NB: These particular tests also make a potentially fragile assumption that
  # the implementation of some preserves the order of entries, it would be
  # better if we sorted the results by :id or used an order-insensitive array
  # comparator

  it 'returns correct data from low-level methods' do
    expect(hardcoded_reference_list.all).to eq([
                            { id: '1', name: 'Alaric', child: false },
                            { id: '2', name: 'Sarah', child: false },
                            { id: '3', name: 'Jean', child: true },
                            { id: '4', name: 'Mary', child: true }
                          ])
    expect(hardcoded_reference_list.all_as_hash).to eq({
                                    '1' => { id: '1', name: 'Alaric', child: false },
                                    '2' => { id: '2', name: 'Sarah', child: false },
                                    '3' => { id: '3', name: 'Jean', child: true },
                                    '4' => { id: '4', name: 'Mary', child: true }
                                  })

    expect(hardcoded_reference_list.one('1')).to eq({ id: '1', name: 'Alaric', child: false })
    expect(hardcoded_reference_list.one('nonexistant')).to eq(nil)
  end

  it 'returns correct data when filtered with some' do
    expect(hardcoded_reference_list.some({ child: true })).to eq([
                                              { id: '3', name: 'Jean', child: true },
                                              { id: '4', name: 'Mary', child: true }
                                            ])

    expect(hardcoded_reference_list.some({ child: false })).to eq([
                                               { id: '1', name: 'Alaric', child: false },
                                               { id: '2', name: 'Sarah', child: false }
                                             ])

    expect(hardcoded_reference_list.some({})).to eq([
                                 { id: '1', name: 'Alaric', child: false },
                                 { id: '2', name: 'Sarah', child: false },
                                 { id: '3', name: 'Jean', child: true },
                                 { id: '4', name: 'Mary', child: true }
                               ])

    expect(hardcoded_reference_list.some(nil)).to eq([
                                  { id: '1', name: 'Alaric', child: false },
                                  { id: '2', name: 'Sarah', child: false },
                                  { id: '3', name: 'Jean', child: true },
                                  { id: '4', name: 'Mary', child: true }
                                ])
  end

  it 'returns correct data reformatted by some_by_field' do
    expect(hardcoded_reference_list.some_by_field(:child)).to eq({
                                              true => [
                                                { id: '3', name: 'Jean', child: true },
                                                { id: '4', name: 'Mary', child: true }
                                              ],
                                              false => [
                                                { id: '1', name: 'Alaric', child: false },
                                                { id: '2', name: 'Sarah', child: false }
                                              ]
                                            })

    expect(hardcoded_reference_list.some_by_field(:child, { name: 'Alaric' })).to eq({
                                                                  false => [
                                                                    { id: '1', name: 'Alaric', child: false }
                                                                  ]
                                                                })

    expect(hardcoded_reference_list.some_by_field(:nonexistant)).to eq({})
  end
end

require 'rails_helper'

RSpec.describe DfE::ReferenceData::TweakedReferenceList do
  hrl = DfE::ReferenceData::HardcodedReferenceList.new(
    {
      '1' => { name: 'Alaric', child: false },
      '2' => { name: 'Sarah', child: false },
      '3' => { name: 'Jean', child: true },
      '4' => { name: 'Mary', child: true }
    }
  )

  trl = DfE::ReferenceData::TweakedReferenceList.new(
    hrl,
    {
      '1' => nil,
      '2' => { favourite_pokemon: 'Eevee' },
      '5' => { name: 'Helium', cat: true }
    }
  )

  # NB: These particular tests also make a potentially fragile assumption that
  # the implementation of some preserves the order of entries, it would be
  # better if we sorted the results by :id or used an order-insensitive array
  # comparator

  it 'returns correct data from low-level methods' do
    expect(trl.all).to eq([
                            { id: '2', name: 'Sarah', child: false, favourite_pokemon: 'Eevee' },
                            { id: '3', name: 'Jean', child: true },
                            { id: '4', name: 'Mary', child: true },
                            { id: '5', name: 'Helium', cat: true }
                          ])

    expect(trl.all_as_hash).to eq({
                                    '2' => { id: '2', name: 'Sarah', child: false,
                                             favourite_pokemon: 'Eevee' },
                                    '3' => { id: '3', name: 'Jean', child: true },
                                    '4' => { id: '4', name: 'Mary', child: true },
                                    '5' => { id: '5', name: 'Helium', cat: true }
                                  })

    expect(trl.one('1')).to eq(nil)
    expect(trl.one('2')).to eq({ id: '2', name: 'Sarah', child: false, favourite_pokemon: 'Eevee' })
    expect(trl.one('5')).to eq({ id: '5', name: 'Helium', cat: true })
  end
end

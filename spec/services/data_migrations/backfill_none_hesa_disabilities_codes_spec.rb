require 'rails_helper'

RSpec.describe DataMigrations::BackfillNoneHesaDisabilitiesCodes do
  describe '#change' do
    it 'adds 00 HESA code to application forms with empty equality and diversity hesa disabilities codes' do
      af1 = create(:application_form, equality_and_diversity: { sex: 'female', disabilities: [], hesa_disabilities: [] })
      af2 = create(:application_form, equality_and_diversity: { disabilities: [], hesa_disabilities: [] })
      af3 = create(:application_form, equality_and_diversity: { disabilities: %w[Blind], hesa_disabilities: %w[58] })
      af4 = create(:application_form, equality_and_diversity: { disabilities: [] })

      described_class.new.change

      expect(af1.reload.equality_and_diversity).to eq(
        'sex' => 'female',
        'disabilities' => [],
        'hesa_disabilities' => %w[00],
      )
      expect(af2.reload.equality_and_diversity).to eq(
        'disabilities' => [],
        'hesa_disabilities' => %w[00],
      )
      expect(af3.reload.equality_and_diversity).to eq(
        'disabilities' => %w[Blind],
        'hesa_disabilities' => %w[58],
      )
      expect(af4.reload.equality_and_diversity).to eq(
        'disabilities' => [],
        'hesa_disabilities' => %w[00],
      )
    end
  end
end

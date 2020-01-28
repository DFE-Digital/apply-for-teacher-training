require 'rails_helper'

RSpec.describe GetBreaksInMonths do
  describe '.call' do
    let(:jan2019) { Time.zone.local(2019, 1, 1) }

    context 'when there is one month break' do
      it 'returns 1 month break' do
        expect(GetBreaksInMonths.call(jan2019, jan2019 + 1.month)).to eq(0)
        expect(GetBreaksInMonths.call(jan2019, jan2019 + 2.months)).to eq(1)
      end
    end

    context 'when end_date is not specified' do
      it 'returns no break' do
        Timecop.freeze(Time.zone.local(2020, 1, 1)) do
          expect(GetBreaksInMonths.call(jan2019, nil)).to eq(11)
        end
      end
    end
  end
end

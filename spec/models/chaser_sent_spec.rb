require 'rails_helper'

RSpec.describe ChaserSent do
  it { is_expected.to belong_to(:chased) }

  describe '.since_service_opened' do
    context 'find' do
      it 'returns records created this cycle' do
        this_year = create(:chaser_sent)

        travel_temporarily_to(previous_timetable.find_opens_at) do
          create(:chaser_sent)
        end

        expect(described_class.since_service_opened(:find)).to contain_exactly(this_year)
      end
    end

    context 'apply' do
      it 'returns records created this cycle', time: mid_cycle do
        this_year = create(:chaser_sent)

        travel_temporarily_to(previous_timetable.find_opens_at) do
          create(:chaser_sent)
        end

        expect(described_class.since_service_opened(:apply)).to contain_exactly(this_year)
      end
    end
  end
end

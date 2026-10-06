require 'rails_helper'

RSpec.describe EndOfCycle::GenerateNewCycle do
  include ActiveSupport::Testing::TimeHelpers

  describe '#perform' do
    it 'does not generate any cycle' do
      travel_to(Time.zone.parse('2027-06-22')) do
        described_class.new.perform
        expect(RecruitmentCycleTimetable.three_timetables_from_now).to be_nil
      end
    end

    it 'generates a third forward cycle in July' do
      travel_to(Time.zone.parse('2027-07-1')) do
        described_class.new.perform
        expect(RecruitmentCycleTimetable.three_timetables_from_now.present?).to be(true)

        recruitment_cycles = RecruitmentCycleTimetable.count
        described_class.new.perform
        expect(recruitment_cycles).to eq(RecruitmentCycleTimetable.count)
      end
    end
  end
end

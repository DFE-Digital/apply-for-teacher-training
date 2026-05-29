require 'rails_helper'

RSpec.describe SupportInterface::CycleSwitcherForm do
  describe 'attributes' do
    it 'has the same attributes as a recruitment cycle timetable' do
      expect(described_class.new).to have_attributes(
        find_opens_at: nil,
        apply_opens_at: nil,
        apply_deadline_at: nil,
        reject_by_default_at: nil,
        decline_by_default_at: nil,
        find_closes_at: nil,
        winter_reject_by_default_at: nil,
        winter_decline_by_default_at: nil,
      )
    end
  end

  describe '.persist' do
    it 'updates the recruitment cycle timetable, but persist the original times' do
      timetable = current_timetable
      year = timetable.recruitment_cycle_year
      attributes = {
        find_opens_at: "01/01/#{year}".to_time,
        apply_opens_at: "02/01/#{year}".to_time,
        apply_deadline_at: "03/01/#{year}".to_time,
        reject_by_default_at: "04/01/#{year}".to_time,
        decline_by_default_at: "05/01/#{year}".to_time,
        find_closes_at: "06/01/#{year}".to_time,
        winter_reject_by_default_at: "07/01/#{year}".to_time,
        winter_decline_by_default_at: "08/01/#{year}".to_time,
      }
      described_class.new(attributes, timetable:).persist
      timetable.reload
      expect(timetable.find_opens_at).to eq(Time.zone.parse('09:00', Date.parse("01/01/#{year}")))
      expect(timetable.apply_opens_at).to eq(Time.zone.parse('09:00', Date.parse("02/01/#{year}")))
      expect(timetable.apply_deadline_at).to eq(Time.zone.parse('18:00', Date.parse("03/01/#{year}")))
      expect(timetable.reject_by_default_at).to eq(Time.zone.parse('23:59', Date.parse("04/01/#{year}")))
      expect(timetable.decline_by_default_at).to eq(Time.zone.parse('23:59', Date.parse("05/01/#{year}")))
      expect(timetable.find_closes_at).to eq(Time.zone.parse('23:59', Date.parse("06/01/#{year}")))
      expect(timetable.winter_reject_by_default_at).to eq(Time.zone.parse('23:59', Date.parse("07/01/#{year}")))
      expect(timetable.winter_decline_by_default_at).to eq(Time.zone.parse('23:59', Date.parse("08/01/#{year}")))
    end
  end
end

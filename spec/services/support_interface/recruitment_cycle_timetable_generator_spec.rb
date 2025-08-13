require 'rails_helper'

RSpec.describe SupportInterface::RecruitmentCycleTimetableGenerator do
  let(:generate_timetables) { described_class.call(year) }

  before { RecruitmentCycleTimetable.destroy_all }

  context 'timetable already exists' do
    let(:year) { 2020 }

    it 'returns the timetable' do
      result = generate_timetables
      expect(result.recruitment_cycle_year).to eq 2020
    end
  end

  context 'year is before first Apply year' do
    let(:year) { 2018 }

    it 'raises error' do
      expect { generate_timetables }.to raise_error(SupportInterface::RecruitmentCycleTimetableGeneratorError)
    end
  end

  context 'year is more than 10 cycles from the last one' do
    let(:year) { last_timetable.recruitment_cycle_year + 12 }

    it 'raises error' do
      expect { generate_timetables }.to raise_error(SupportInterface::RecruitmentCycleTimetableGeneratorError)
    end
  end

  context 'year is 10 years greater than the last timetable' do
    let(:year) { last_timetable.recruitment_cycle_year + 10 }
    let(:timetables) { RecruitmentCycleTimetable.where('recruitment_cycle_year > ?', 2027) }

    it 'returns the table with the year given' do
      result = generate_timetables
      expect(result.recruitment_cycle_year).to eq year
    end

    it 'creates 10 new timetables' do
      seed_timetables
      expect { generate_timetables }.to change { RecruitmentCycleTimetable.count }.by(10)
    end

    it 'all timetables have find_closes_at dates between 28 Sep and 5 Oct' do
      generate_timetables
      timetables.pluck(:recruitment_cycle_year, :find_closes_at).each do |recruitment_cycle_year, find_closes_at|
        earliest_date = Time.zone.local(recruitment_cycle_year, 9, 28)
        latest_date = Time.zone.local(recruitment_cycle_year, 10, 5).end_of_day
        expect(find_closes_at.between?(earliest_date, latest_date)).to be true
      end
    end

    it 'all timetables have find_opens_at dates that are between 29 Sept and 5 Oct' do
      generate_timetables
      timetables.pluck(:recruitment_cycle_year, :find_opens_at).each do |recruitment_cycle_year, find_opens_at|
        earliest_date = Time.zone.local(recruitment_cycle_year - 1, 9, 29)
        latest_date = Time.zone.local(recruitment_cycle_year - 1, 10, 12)
        expect(find_opens_at.between?(earliest_date, latest_date)).to be true
      end
    end

    it 'all reject_by_default_at dates are on a wednesday in September' do
      generate_timetables
      timetables.pluck(:reject_by_default_at).each do |reject_by_default_at|
        expect(reject_by_default_at.wednesday?).to be true
        expect(reject_by_default_at.month).to eq 9
      end
    end

    it 'all apply_deadline_at dates are on a Tuesday in September' do
      generate_timetables
      timetables.pluck(:apply_deadline_at).each do |apply_deadline_at|
        expect(apply_deadline_at.tuesday?).to be true
        expect(apply_deadline_at.month).to eq 9
      end
    end
  end
end

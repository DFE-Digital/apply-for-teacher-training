require 'rails_helper'

RSpec.describe Interview, type: :model do
  subject(:interview) { described_class.new }

  describe 'validations' do
    it { is_expected.to belong_to(:application_choice) }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to validate_presence_of(:date_and_time) }
  end

  describe 'scopes' do
    let!(:upcoming_not_today_interview) { create(:interview, date_and_time: 1.day.from_now) }
    let!(:upcoming_today_interview) { create(:interview, date_and_time: [1.hour.from_now, Time.zone.now.end_of_day].min) }
    let!(:past_today_interview) { create(:interview, date_and_time: [1.hour.ago, Time.zone.now.beginning_of_day].max) }
    let!(:past_not_today_interview) { create(:interview, date_and_time: 1.day.ago) }

    describe '.upcoming' do
      it 'returns interviews happening today or in the future' do
        expect(described_class.upcoming).to contain_exactly(past_today_interview, upcoming_today_interview, upcoming_not_today_interview)
      end
    end

    describe '.past' do
      it 'returns interviews happening before the start of today' do
        expect(described_class.past).to contain_exactly(past_not_today_interview)
      end
    end

    describe '.upcoming_not_today' do
      it 'returns interviews happening after the end of today' do
        expect(described_class.upcoming_not_today).to contain_exactly(upcoming_not_today_interview)
      end
    end
  end
end

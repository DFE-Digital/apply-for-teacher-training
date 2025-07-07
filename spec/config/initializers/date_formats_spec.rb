require 'rails_helper'

RSpec.describe 'Time::DATE_FORMATS' do
  describe ':govuk_date_and_time, :govuk_time formats' do
    it 'formats time to indicate midday' do
      date_and_time = Time.zone.local(2020, 12, 25, 12, 0, 59)
      expect(date_and_time.to_fs(:govuk_date_and_time)).to eq('25 December 2020 at 12pm (midday) UK time')
      expect(date_and_time.to_fs(:govuk_time)).to eq('12pm (midday) UK time')
    end

    it 'formats time to indicate midnight' do
      date_and_time = Time.zone.local(2020, 12, 25, 0, 0, 59)
      expect(date_and_time.to_fs(:govuk_date_and_time)).to eq('25 December 2020 at 12am (midnight) UK time')
      expect(date_and_time.to_fs(:govuk_time)).to eq('12am (midnight) UK time')
    end

    it 'formats time with minutes if the time is not on the hour' do
      date_and_time = Time.zone.local(2020, 12, 25, 12, 1, 0)
      expect(date_and_time.to_fs(:govuk_date_and_time)).to eq('25 December 2020 at 12:01pm UK time')
      expect(date_and_time.to_fs(:govuk_time)).to eq('12:01pm UK time')
    end

    it 'formats time without minutes if the time is on the hour' do
      date_and_time = Time.zone.local(2020, 12, 25, 15)
      expect(date_and_time.to_fs(:govuk_date_and_time)).to eq('25 December 2020 at 3pm UK time')
      expect(date_and_time.to_fs(:govuk_time)).to eq('3pm UK time')
    end

    it 'does not pad single-digit day and hour with whitespace' do
      date_and_time = Time.zone.local(2020, 12, 5, 6, 10, 0)
      expect(date_and_time.to_fs(:govuk_date_and_time)).to eq('5 December 2020 at 6:10am UK time')
      expect(date_and_time.to_fs(:govuk_time)).to eq('6:10am UK time')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Time::DATE_FORMATS' do
  describe ':govuk_date_and_time, :govuk_time formats' do
    it 'formats time to indicate midday' do
      date_and_time = Time.zone.local(2020, 12, 25, 12, 0, 59)
      expect(date_and_time.to_s(:govuk_date_and_time)).to eq('25 December 2020 at 12pm (midday)')
      expect(date_and_time.to_s(:govuk_time)).to eq('12pm (midday)')
    end

    it 'formats time to indicate midnight' do
      date_and_time = Time.zone.local(2020, 12, 25, 0, 0, 59)
      expect(date_and_time.to_s(:govuk_date_and_time)).to eq('25 December 2020 at 12am (midnight)')
      expect(date_and_time.to_s(:govuk_time)).to eq('12am (midnight)')
    end

    it 'formats time with minutes otherwise' do
      date_and_time = Time.zone.local(2020, 12, 25, 12, 1, 0)
      expect(date_and_time.to_s(:govuk_date_and_time)).to eq('25 December 2020 at 12:01pm')
      expect(date_and_time.to_s(:govuk_time)).to eq('12:01pm')
    end
  end
end

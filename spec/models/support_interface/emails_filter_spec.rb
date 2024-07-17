require 'rails_helper'

RSpec.describe SupportInterface::EmailsFilter do
  include ActiveSupport::Testing::TimeHelpers

  describe '#applied_filers' do
    it 'adds a default of 10 for `days_ago`' do
      emails_filter = described_class.new(params: {})

      expect(emails_filter.applied_filters).to include({ days_ago: 10 })
    end

    it 'respects the given value for `days_ago`' do
      emails_filter = described_class.new(params: { days_ago: 20 })

      expect(emails_filter.applied_filters).to include({ days_ago: 20 })
    end

    it 'adds `created_since` based on `days_ago`' do
      travel_to Time.zone.parse('2024-07-17 12:00:00') do
        emails_filter = described_class.new(params: { days_ago: 10 })

        expect(emails_filter.applied_filters).to include({ created_since: Time.zone.parse('2024-07-07 00:00:00') })
      end
    end

    it 'adds `created_since` based on `days_ago` when `days_ago` is a string' do
      travel_to Time.zone.parse('2024-07-17 12:00:00') do
        emails_filter = described_class.new(params: { days_ago: '10' })

        expect(emails_filter.applied_filters).to include({ created_since: Time.zone.parse('2024-07-07 00:00:00') })
      end
    end

    it 'removes empty arrays params on initialization' do
      emails_filter = described_class.new(params: { some_array: ['', nil], other_array: ['1', 2] })

      expect(emails_filter.applied_filters).to include(some_array: [], other_array: ['1', 2])
    end
  end
end

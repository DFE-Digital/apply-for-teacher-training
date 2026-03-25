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

  describe '#filters' do
    it 'returns an array of filters' do
      emails_filter = described_class.new(params: {})

      expect(emails_filter.filters).to be_an(Array)
    end

    it 'returns an array of filters with the correct keys' do
      emails_filter = described_class.new(params: {})

      expect(emails_filter.filters).to all(include(:type, :heading, :name))
    end

    context 'when application form id value is present in the params' do
      it 'returns a search filter with the correct value' do
        emails_filter = described_class.new(params: { application_form_id: '123' })

        application_form_filter = emails_filter.filters.find { |filter| filter[:name] == 'application_form_id' }

        expect(application_form_filter).to eq(type: :search, heading: 'Application form ID', value: '123', name: 'application_form_id')
      end
    end

    context 'when days ago value is present in the params' do
      context 'when no other params is present' do
        it 'returns no search filter for days ago' do
          emails_filter = described_class.new(params: { days_ago: 12 })

          days_ago_filter = emails_filter.filters.find { |filter| filter[:name] == 'days_ago' }

          expect(days_ago_filter).to be_nil
        end
      end

      context 'when other params are present' do
        it 'returns a search filter with the correct value' do
          emails_filter = described_class.new(params: { days_ago: 12, to: 'bob@example.com' })

          days_ago_filter = emails_filter.filters.find { |filter| filter[:name] == 'days_ago' }

          expect(days_ago_filter).to eq(type: :search, heading: 'Days ago', value: '12', name: 'days_ago')
        end
      end
    end

    context 'when to value is present in the params' do
      it 'returns a search filter with the correct value' do
        emails_filter = described_class.new(params: { to: 'bob@example.com' })

        recipient_filter = emails_filter.filters.find { |filter| filter[:name] == 'to' }

        expect(recipient_filter).to eq(type: :search, heading: 'Recipient (To)', value: 'bob@example.com', name: 'to')
      end
    end

    context 'when subject value is present in the params' do
      it 'returns a search filter with the correct value' do
        emails_filter = described_class.new(params: { subject: 'A subject' })

        subject_filter = emails_filter.filters.find { |filter| filter[:name] == 'subject' }

        expect(subject_filter).to eq(type: :search, heading: 'Subject', value: 'A subject', name: 'subject')
      end
    end

    context 'when notify reference value is present in the params' do
      it 'returns a search filter with the correct value' do
        emails_filter = described_class.new(params: { notify_reference: '123ABC' })

        notify_filter = emails_filter.filters.find { |filter| filter[:name] == 'notify_reference' }

        expect(notify_filter).to eq(type: :search, heading: 'Notify reference', value: '123ABC', name: 'notify_reference')
      end
    end

    context 'when email body value is present in the params' do
      it 'returns a search filter with the correct value' do
        emails_filter = described_class.new(params: { email_body: 'Hello there' })

        email_body_filter = emails_filter.filters.find { |filter| filter[:name] == 'email_body' }

        expect(email_body_filter).to eq(type: :search, heading: 'Email body', value: 'Hello there', name: 'email_body')
      end
    end

    context 'when deliver_status value is present in the params' do
      it 'returns a checkboxes filter with the correct value' do
        emails_filter = described_class.new(params: { delivery_status: ['delivered'] })

        delivery_status_filter = emails_filter.filters.find { |filter| filter[:name] == 'delivery_status' }

        expect(delivery_status_filter).to eq(
          type: :checkboxes,
          heading: 'Delivery status',
          name: 'delivery_status',
          options: [
            {
              value: 'not_tracked',
              label: 'Not tracked',
              checked: false,
            },
            {
              value: 'notify_error',
              label: 'Notify error',
              checked: false,
            },
            {
              value: 'pending',
              label: 'Pending',
              checked: false,
            },
            {
              value: 'skipped',
              label: 'Skipped',
              checked: false,
            },
            {
              value: 'unknown',
              label: 'Unknown',
              checked: false,
            },
            {
              value: 'delivered',
              label: 'Delivered',
              checked: true,
            },
            {
              value: 'permanent_failure',
              label: 'Permanent failure',
              checked: false,
            },
            {
              value: 'temporary_failure',
              label: 'Temporary failure',
              checked: false,
            },
            {
              value: 'technical_failure',
              label: 'Technical failure',
              checked: false,
            },
          ],
        )
      end
    end

    context 'when mailer value is present in the params' do
      it 'returns a checkboxes filter with the correct value' do
        emails_filter = described_class.new(params: { mailer: ['support_mailer'] })

        mailer_filter = emails_filter.filters.find { |filter| filter[:name] == 'mailer' }

        expect(mailer_filter).to eq(
          type: :checkboxes,
          heading: 'Mailer',
          name: 'mailer',
          options: [
            {
              value: 'support_mailer',
              label: 'Support mailer',
              checked: true,
            },
            {
              value: 'referee_mailer',
              label: 'Referee mailer',
              checked: false,
            },
            {
              value: 'provider_mailer',
              label: 'Provider mailer',
              checked: false,
            },
            {
              value: 'candidate_mailer',
              label: 'Candidate mailer',
              checked: false,
            },
            {
              value: 'authentication_mailer',
              label: 'Authentication mailer',
              checked: false,
            },
          ],
        )
      end
    end
  end

  describe '#filtered?' do
    %i[to subject notify_reference email_body delivery_status mailer mail_template application_form_id].each do |filter|
      context "when #{filter} value is present in the params" do
        it 'returns true' do
          expect(described_class.new(params: { "#{filter}": 'valid' }).filtered?).to be(true)
        end
      end
    end

    context 'when an invalid filter is present in the params' do
      it 'returns false' do
        expect(described_class.new(params: { random: 'valid' }).filtered?).to be(false)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ViewHelper, type: :helper do
  describe '#govuk_back_link_to' do
    it 'returns an anchor tag with the govuk-back-link class and defaults to "Back"' do
      anchor_tag = helper.govuk_back_link_to('https://localhost:0103/snek/ssss')

      expect(anchor_tag).to eq("<a class=\"govuk-back-link govuk-!-display-none-print\" href=\"https://localhost:0103/snek/ssss\">Back</a>\n")
    end

    it 'returns an anchor tag with the govuk-back-link class and with the body if given' do
      anchor_tag = helper.govuk_back_link_to('https://localhost:0103/lion/roar', 'Back to application')

      expect(anchor_tag).to eq("<a class=\"govuk-back-link govuk-!-display-none-print\" href=\"https://localhost:0103/lion/roar\">Back to application</a>\n")
    end

    it 'returns an anchor tag with the app-back-link--no-js class if given :back as an argument' do
      anchor_tag = helper.govuk_back_link_to(:back)

      expect(anchor_tag).to eq("<a class=\"govuk-back-link govuk-!-display-none-print app-back-link--fallback app-back-link--no-js\" href=\"javascript:history.back()\">Back</a>\n")
    end
  end

  describe '#bat_contact_mail_to' do
    it 'returns an anchor tag with href="mailto:" and the govuk-link class' do
      anchor_tag = helper.bat_contact_mail_to

      expect(anchor_tag).to eq('<a class="govuk-link" href="mailto:becomingateacher@digital.education.gov.uk">becomingateacher<wbr>@digital.education.gov.uk</a>')
    end

    it 'returns an anchor tag with the name' do
      anchor_tag = helper.bat_contact_mail_to('Contact the Becoming a Teacher team')

      expect(anchor_tag).to eq('<a class="govuk-link" href="mailto:becomingateacher@digital.education.gov.uk">Contact the Becoming a Teacher team</a>')
    end

    it 'returns an anchor tag with additional HTML options' do
      anchor_tag = helper.bat_contact_mail_to(html_options: { subject: 'Support and guidance', class: 'govuk-link--no-visited-state' })

      expect(anchor_tag).to eq('<a class="govuk-link govuk-link--no-visited-state" href="mailto:becomingateacher@digital.education.gov.uk?subject=Support%20and%20guidance">becomingateacher<wbr>@digital.education.gov.uk</a>')
    end
  end

  describe 'application date helpers' do
    before do
      @application_dates = instance_double(
        ApplicationDates,
        submitted_at: Time.zone.local(2019, 10, 22, 12, 0, 0),
        reject_by_default_at: Time.zone.local(2019, 12, 17, 12, 0, 0),
      )
      allow(ApplicationDates).to receive(:new).and_return(@application_dates)
    end

    describe '#submitted_at_date' do
      it 'renders with correct submission date' do
        expect(helper.submitted_at_date).to include('22 October 2019')
      end
    end
  end

  describe '#format_months_to_years_and_months' do
    context 'when months is 12 months' do
      it 'returns years and months' do
        expect(helper.format_months_to_years_and_months(12)).to eq('1 year')
      end
    end

    context 'when months is less than 12 months' do
      it 'returns just the months' do
        expect(helper.format_months_to_years_and_months(5)).to eq('5 months')
      end
    end

    context 'when months is more than 12 months' do
      it 'returns just the years and months' do
        expect(helper.format_months_to_years_and_months(27)).to eq('2 years and 3 months')
      end
    end
  end

  describe '#days_until' do
    it 'returns a phrase expressing the number of days' do
      expect(helper.days_until(Date.current + 2)).to eq('2 days')
      expect(helper.days_until(Date.current + 1)).to eq('1 day')
      expect(helper.days_until(Date.current + 0.5)).to eq('less than 1 day')
    end
  end

  describe '#time_is_today_or_tomorrow?' do
    it 'is true for now' do
      expect(helper.time_is_today_or_tomorrow?(Time.zone.now)).to be true
    end

    it 'is true for a time in an hour' do
      expect(helper.time_is_today_or_tomorrow?(Time.zone.now + 1.hour)).to be true
    end

    it 'is not true for a time 24 hours ago' do
      expect(helper.time_is_today_or_tomorrow?(Time.zone.now - 24.hours)).to be false
    end

    it 'is not true for a time after tomorrow' do
      expect(helper.time_is_today_or_tomorrow?(Time.zone.now + 49.hours)).to be false
    end
  end

  describe '#time_today_or_tomorrow' do
    it 'returns the time tomorrow for a time tomorrow' do
      time = Time.zone.tomorrow.midnight + 3.hours
      expect(helper.time_today_or_tomorrow(time)).to eq '3am tomorrow'
    end

    it 'returns the bare time for a time today' do
      Timecop.freeze(Time.zone.now.midnight) do
        time = Time.zone.now + 6.hours
        expect(helper.time_today_or_tomorrow(time)).to eq '6am'
      end
    end

    it 'throws an exception when the time is not today or tomorrow' do
      time = Time.zone.now + 2.days
      expect { helper.time_today_or_tomorrow(time) }.to raise_error(/was expected to be today or tomorrow/)
    end
  end

  describe '#date_and_time_today_or_tomorrow' do
    it 'returns the time tomorrow for a time tomorrow' do
      time = Time.zone.tomorrow.midnight + 3.hours
      expect(helper.date_and_time_today_or_tomorrow(time)).to eq 'tomorrow (2 November 2021 at 3am)'
    end

    it 'returns the bare time for a time today' do
      Timecop.freeze(Time.zone.now.midnight) do
        time = Time.zone.now + 6.hours
        expect(helper.date_and_time_today_or_tomorrow(time)).to eq 'today (1 November 2021 at 6am)'
      end
    end

    it 'throws an exception when the time is not today or tomorrow' do
      time = Time.zone.now + 2.days
      expect { helper.date_and_time_today_or_tomorrow(time) }.to raise_error(/was expected to be today or tomorrow/)
    end
  end

  describe '#formatted_percentage' do
    it 'returns the correct value for a whole number percentage' do
      expect(helper.formatted_percentage(5, 10)).to eq '50%'
    end

    it 'returns the correct value for fractional percentage' do
      expect(helper.formatted_percentage(3, 9)).to eq '33.33%'
    end

    it 'returns the correct value for a zero percentage' do
      expect(helper.formatted_percentage(0, 24)).to eq '0%'
    end

    it 'handles NaN' do
      expect(helper.formatted_percentage(1, 0)).to eq '-'
    end
  end
end

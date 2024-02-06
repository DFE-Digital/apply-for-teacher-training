require 'rails_helper'

RSpec.describe ViewHelper do
  describe '#govuk_back_link_to' do
    it 'returns an anchor tag with the govuk-back-link class and defaults to "Back"' do
      anchor_tag = helper.govuk_back_link_to('https://localhost:0103/snek/ssss')

      expect(anchor_tag).to eq('<a class="govuk-back-link govuk-!-display-none-print" href="https://localhost:0103/snek/ssss">Back</a>')
    end

    it 'returns an anchor tag with the govuk-back-link class and with the body if given' do
      anchor_tag = helper.govuk_back_link_to('https://localhost:0103/lion/roar', 'Back to application')

      expect(anchor_tag).to eq('<a class="govuk-back-link govuk-!-display-none-print" href="https://localhost:0103/lion/roar">Back to application</a>')
    end

    it 'returns an anchor tag with the current namespace root if given :back as an argument with no referer' do
      anchor_tag = helper.govuk_back_link_to(:back)

      expect(anchor_tag).to eq('<a class="govuk-back-link govuk-!-display-none-print" href="/">Back</a>')
    end

    it 'uses the HTTP referer if available when :back is passed' do
      helper.request.env['HTTP_REFERER'] = 'foo'

      anchor_tag = helper.govuk_back_link_to(:back)

      expect(anchor_tag).to eq('<a class="govuk-back-link govuk-!-display-none-print" href="foo">Back</a>')
    end

    it 'discards the HTTP referer and defaults to current namespace root if the referer came from another domain' do
      helper.request.env['HTTP_REFERER'] = 'http://some.other.domain/path'

      anchor_tag = helper.govuk_back_link_to(:back)

      expect(anchor_tag).to eq('<a class="govuk-back-link govuk-!-display-none-print" href="/">Back</a>')
    end

    context 'when path ends with candidate/application/details' do
      it 'renders a link with the text Back to your details' do
        anchor_tag = helper.govuk_back_link_to(candidate_interface_continuous_applications_details_path)

        expect(anchor_tag).to eq('<a class="govuk-back-link govuk-!-display-none-print" href="/candidate/application/details">Back to your details</a>')
      end
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

      it 'returns nil if there is no submitted at date' do
        @application_dates = instance_double(
          ApplicationDates,
          submitted_at: nil,
          reject_by_default_at: Time.zone.local(2019, 12, 17, 12, 0, 0),
        )
        allow(ApplicationDates).to receive(:new).and_return(@application_dates)

        expect(helper.submitted_at_date).to be_nil
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

    it 'returns the correct value for a zero percentage of a zero total' do
      expect(helper.formatted_percentage(0, 0)).to eq '0%'
    end

    it 'handles NaN' do
      expect(helper.formatted_percentage(1, 0)).to eq '-'
    end
  end
end

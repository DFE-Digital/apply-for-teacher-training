require 'rails_helper'

RSpec.describe ProviderInterface::InterviewDetailsComponent do
  let(:date_and_time) { Time.zone.local(2020, 1, 12, 15, 30) }
  let(:provider) { build_stubbed(:provider, name: 'Teaching School') }
  let(:application_choice) { build_stubbed(:application_choice, id: 1) }
  let(:location) { 'Zoom' }
  let(:additional_details) { 'Do not be late' }
  let(:multiple_application_providers) { false }
  let(:interview_form) do
    instance_double(
      ProviderInterface::InterviewWizard,
      date_and_time: date_and_time,
      provider: provider,
      location: location,
      additional_details: additional_details,
      application_choice: application_choice,
      multiple_application_providers?: multiple_application_providers,
    )
  end
  let(:render) { render_inline(described_class.new(interview_form)) }

  it 'renders the interview date' do
    date_row = find_table_row('Date')
    expect(date_row.text).to include('12 January 2020')
  end

  it 'renders the interview time' do
    time_row = find_table_row('Time')
    expect(time_row.text).to include('3:30pm')
  end

  it 'renders the provider name' do
    provider_row = find_table_row('Organisation carrying out interview')
    expect(provider_row.text).to include('Teaching School')
  end

  it 'renders the interview location' do
    location_row = find_table_row('Address or online meeting details')
    expect(location_row.text).to include('Zoom')
  end

  it 'renders additional_details' do
    additional_details_row = find_table_row('Additional details')
    expect(additional_details_row.text).to include('Do not be late')
  end

  context 'no additional_details are set' do
    let(:additional_details) { '' }

    it 'renders None in the additional details row' do
      additional_details_row = find_table_row('Additional details')
      expect(additional_details_row.text).to include('None')
    end
  end

  describe 'renders change links with the correct anchor for' do
    it 'date' do
      date_row = find_table_row('Date')
      expect(date_row.css('a').attr('href').value).to eq('/provider/applications/1/interviews/new#provider_interface_interview_wizard_date_3i')
    end

    it 'time' do
      time_row = find_table_row('Time')
      expect(time_row.css('a').attr('href').value).to eq('/provider/applications/1/interviews/new#provider-interface-interview-wizard-time-field')
    end

    context 'provider' do
      let(:multiple_application_providers) { true }

      it 'when multiple providers' do
        provider_row = find_table_row('Organisation carrying out interview')
        expect(provider_row.css('a').attr('href').value).to eq("/provider/applications/1/interviews/new#provider-interface-interview-wizard-provider-id-#{provider.id}-field")
      end
    end

    it 'location' do
      location_row = find_table_row('Address or online meeting details')
      expect(location_row.css('a').attr('href').value).to eq('/provider/applications/1/interviews/new#provider-interface-interview-wizard-location-field')
    end

    it 'additional_details' do
      additional_details_row = find_table_row('Additional details')
      expect(additional_details_row.css('a').attr('href').value).to eq('/provider/applications/1/interviews/new#provider-interface-interview-wizard-additional-details-field')
    end
  end

  describe 'renders no change change link' do
    context 'provider' do
      let(:multiple_application_providers) { false }

      it 'when single provider' do
        provider_row = find_table_row('Organisation carrying out interview')
        expect(provider_row.css('a')).to be_empty
      end
    end
  end

  def find_table_row(key)
    render.css('.govuk-summary-list__row').select { |row| row.to_html.include?(key) }.first
  end
end

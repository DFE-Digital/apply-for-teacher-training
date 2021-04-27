require 'rails_helper'

RSpec.describe SupportInterface::ValidationErrorsSummaryComponent do
  let(:validation_error_summary) do
    [
      {
        'scope' => '/api/v1/applications',
        'attribute' => 'ParameterInvalid',
        'incidents_last_week' => 0,
        'unique_providers_last_week' => 0,
        'incidents_last_month' => 9,
        'unique_providers_last_month' => 0,
        'incidents_all_time' => 17,
        'unique_providers_all_time' => 1,
      },
    ]
  end
  let(:render_result) { render_inline(component) }

  let(:source_name) { :vendor_api }
  let(:select_sort_options) { [OpenStruct.new(value: 'all_time', text: 'All Time')] }

  subject(:component) do
    described_class.new(
      validation_error_summary: validation_error_summary,
      scoped_error_object: :scope,
      source_name: source_name,
      error_source: :providers,
      select_sort_options: select_sort_options,
    )
  end

  it 'renders the summary form path' do
    expect(render_result.css('.govuk-form')[0].attributes['action'].value).to eq(
      Rails.application.routes.url_helpers.support_interface_validation_errors_vendor_api_summary_path,
    )
  end

  it 'renders the attribute error links with correct scope' do
    expect(render_result.css('.govuk-link')[0].text.strip).to eq('/api/v1/applications')
    expect(render_result.css('.govuk-link')[0].attributes['href'].value).to eq(
      Rails.application.routes.url_helpers.support_interface_validation_errors_vendor_api_search_path(
        scope: '/api/v1/applications',
      ),
    )
    expect(render_result.css('.govuk-link')[1].text.strip).to eq('ParameterInvalid')
    expect(render_result.css('.govuk-link')[1].attributes['href'].value).to eq(
      Rails.application.routes.url_helpers.support_interface_validation_errors_vendor_api_search_path(
        scope: '/api/v1/applications',
        attribute: 'ParameterInvalid',
      ),
    )
  end

  it 'renders the grouped error counts' do
    expect(render_result.css('tr')[2].text.squish).to include('17 1 9 0 0 0')
  end

  it 'renders the error_source label' do
    expect(render_result.text).to include('providers')
  end

  describe '#format_value' do
    context 'with source as vendor API' do
      it 'does not format the object' do
        expect(component.format_value('/api/v1/applications')).to eq('/api/v1/applications')
      end
    end

    context 'with source other than vendor API' do
      let(:source_name) { :candidate }

      it 'formats the object' do
        expect(component.format_value('CandidateInterface::PersonalDetailsForm')).to eq('Personal details form')
      end
    end
  end
end

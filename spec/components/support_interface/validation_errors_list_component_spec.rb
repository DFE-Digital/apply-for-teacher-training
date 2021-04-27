require 'rails_helper'

RSpec.describe SupportInterface::ValidationErrorsListComponent do
  let(:distinct_errors_with_counts) do
    [
      [['/api/v1/applications', 'ParameterInvalid', 'Some error'], 1],
      [['/api/v1/applications/309/confirm-conditions-met', 'ValidationError', 'Another error'], 1],
    ]
  end
  let(:render_result) { render_inline(component) }

  let(:grouped_counts) do
    {
      '/api/v1/applications' => 1,
      '/api/v1/applications/309/confirm-conditions-met' => 1,
    }
  end

  let(:source_name) { :vendor_api }

  subject(:component) do
    described_class.new(
      distinct_errors_with_counts: distinct_errors_with_counts,
      grouped_counts: grouped_counts,
      scoped_error_object: :scope,
      source_name: source_name,
      grouped_counts_label: 'Counts label',
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

  it 'renders the attribute error messages' do
    expect(render_result.css('td p').first.text.strip).to eq('Some error')
  end

  it 'renders the attribute error counts' do
    expect(render_result.css('td.govuk-table__cell--numeric').first.text.strip).to eq('1')
  end

  it 'renders the grouped_counts_label' do
    expect(render_result.text.strip).to include('Counts label')
  end

  it 'renders the grouped counts links' do
    expect(render_result.css('.govuk-link')[4].text.strip).to eq('/api/v1/applications')
    expect(render_result.css('.govuk-link')[4].attributes['href'].value).to eq(
      Rails.application.routes.url_helpers.support_interface_validation_errors_vendor_api_search_path(
        scope: '/api/v1/applications',
      ),
    )
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

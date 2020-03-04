require 'rails_helper'

RSpec.describe ProviderInterface::FilterComponent do
  let(:path) { :provider_interface_applications_path }

  let(:preselected_filters_partial) do
    {
      'status' => {
        'pending-conditions' => 'pending_conditions',
        'awaiting-provider-decision' => 'awaiting_provider_decision',
        'offer' => 'offer',
        'rejected' => 'rejected',
        'withdrawn' => 'withdrawn',
      }, 'provider' => {
          'the-beach-teaching-school' => '2',
        }
    }
  end

  let(:preselected_filters_partial_minus_withdrawn) do
    {
      'status' => {
        'pending-conditions' => 'pending_conditions',
        'awaiting-provider-decision' => 'awaiting_provider_decision',
        'offer' => 'offer',
        'rejected' => 'rejected',
      }, 'provider' => {
          'the-beach-teaching-school' => '2',
        }
    }
  end


  let(:available_filters) do
    [
      {
        heading: 'status',
        checkbox_config: [
          {
            name: 'pending-conditions',
            text: 'Accepted',
            value: 'pending_conditions',
          },
          {
            name: 'recruited',
            text: 'Conditions met',
            value: 'recruited',
          },
          {
            name: 'declined',
            text: 'Declined',
            value: 'declined',
          },
          {
            name: 'awaiting-provider-decision',
            text: 'New',
            value: 'awaiting_provider_decision',
          },
          {
            name: 'offer',
            text: 'Offered',
            value: 'offer',
          },
          {
            name: 'rejected',
            text: 'Rejected',
            value: 'rejected',
          },
          {
            name: 'withdrawn',
            text: 'Application withdrawn',
            value: 'withdrawn',
          },
          {
            name: 'offer-withdrawn',
            text: 'Withdrawn by us',
            value: 'offer_withdrawn',
          },
        ],
      },
      {
        heading: 'provider',
        checkbox_config: [
          {
            name: 'somerset-scitt-consortium',
            text: 'Somerset SCITT consortium',
            value: '1',
          },
          {
            name: 'the-beach-teaching-school',
            text: 'The Beach Teaching School',
            value: '2',
          },

        ],
       },
    ]
  end

  let(:additional_params) do
    {
      sort_by: 'desc',
      sort_order: 'last-updated',
    }
  end

  it 'marks checkboxes as checked if they have already been pre-selected' do
    result = render_inline described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: preselected_filters_partial,
                                        additional_params: additional_params)

    expect(result.css('#status-pending-conditions').attr('checked').value).to eq('checked')
    expect(result.css('#status-recruited').attr('checked')).to eq(nil)
    expect(result.css('#status-declined').attr('checked')).to eq(nil)
    expect(result.css('#status-awaiting-provider-decision').attr('checked').value).to eq('checked')
    expect(result.css('#status-rejected').attr('checked').value).to eq('checked')
    expect(result.css('#status-withdrawn').attr('checked').value).to eq('checked')
    expect(result.css('#provider-somerset-scitt-consortium').attr('checked')).to eq(nil)
    expect(result.css('#provider-the-beach-teaching-school').attr('checked').value).to eq('checked')
  end

  it 'on initial load all of the checkboxes are unchecked' do
    result = render_inline described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: {},
                                        additional_params: additional_params)

    expect(result.css('#status-pending-conditions').attr('checked')).to eq(nil)
    expect(result.css('#status-recruited').attr('checked')).to eq(nil)
    expect(result.css('#status-declined').attr('checked')).to eq(nil)
    expect(result.css('#status-awaiting-provider-decision').attr('checked')).to eq(nil)
    expect(result.css('#status-rejected').attr('checked')).to eq(nil)
    expect(result.css('#status-withdrawn').attr('checked')).to eq(nil)
    expect(result.css('#provider-somerset-scitt-consortium').attr('checked')).to eq(nil)
    expect(result.css('#provider-the-beach-teaching-school').attr('checked')).to eq(nil)
  end

  it 'when filters have been selected filters dialogue to appear' do
    result = render_inline described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: preselected_filters_partial,
                                        additional_params: additional_params)

    expect(result.text).to include('Selected filters')
  end

  it 'selected filters should include tags that match what has been selected for' do
    result = render_inline described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: preselected_filters_partial,
                                        additional_params: additional_params)

    expect(result.css('.moj-filter-tags').text).to include('Accepted', 'New', 'Rejected', 'Application withdrawn', 'The Beach Teaching School')
    expect(result.css('.moj-filter-tags').text).not_to include('Declined', 'Conditions met', 'Somerset SCITT consortium')
  end


  it 'selected filters dialogue should not appear if is nothing filtered for' do
    result = render_inline described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: {},
                                        additional_params: additional_params)

    expect(result.text).not_to include('Selected filters')
  end

  it 'has a clear button when filters have been selected' do
    result = render_inline described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: preselected_filters_partial,
                                        additional_params: additional_params)

    expect(result.text).to include('Clear')
  end

  it 'returns the additional_params as hidden fields' do
    result = render_inline described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: preselected_filters_partial,
                                        additional_params: additional_params)

    expect(result.css('#sort_by').attr('value').value).to eq('desc')
    expect(result.css('#sort_order').attr('value').value).to eq('last-updated')
    expect(result.css('#sort_by').attr('type').value).to eq('hidden')
    expect(result.css('#sort_order').attr('type').value).to eq('hidden')
  end

  it 'can return a full text of a preselected_filters value from the available_filters' do
    filter_component = described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: preselected_filters_partial,
                                        additional_params: additional_params)

    expect(filter_component.retrieve_tag_text('status', 'offer_withdrawn')).to eq('Withdrawn by us')
    expect(filter_component.retrieve_tag_text('provider', '2')).to eq('The Beach Teaching School')
  end

  it 'can create hash for a tag url that doesn\'t include that tag\'s params' do
    filter_component = described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: preselected_filters_partial,
                                        additional_params: additional_params)

    hash = filter_component.build_tag_url_query_params(heading: 'status',
                                               tag_value: 'withdrawn',
                                               preselected_filters: preselected_filters_partial)

    expect(hash).to eq(preselected_filters_partial_minus_withdrawn)
  end

  it 'can create a tag url that doesn\'t include that tag\'s values' do
    result = render_inline described_class.new(path: path,
                                        available_filters: available_filters,
                                        preselected_filters: preselected_filters_partial,
                                        additional_params: additional_params)

    expect(result.css('#tag-rejected').attr('href').value).not_to include('rejected')
    expect(result.css('#tag-rejected').attr('href').value).to include('2')
    expect(result.css('#tag-rejected').attr('href').value).to include('awaiting_provider_decision')
    expect(result.css('#tag-rejected').attr('href').value).to include('offer')
    expect(result.css('#tag-rejected').attr('href').value).to include('pending_conditions')
    expect(result.css('#tag-rejected').attr('href').value).to include('withdrawn')
  end
end

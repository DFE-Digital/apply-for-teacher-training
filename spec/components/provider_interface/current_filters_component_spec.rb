require 'rails_helper'

RSpec.describe ProviderInterface::CurrentFiltersComponent, type: :view do
  let(:applied_filters_partial) do
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

  let(:applied_filters_partial_minus_withdrawn) do
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
        input_config: [
          {
            type: 'checkbox',
            name: 'pending-conditions',
            text: 'Accepted',
            value: 'pending_conditions',
          },
          {
            type: 'checkbox',
            name: 'recruited',
            text: 'Conditions met',
            value: 'recruited',
          },
          {
            type: 'checkbox',
            name: 'declined',
            text: 'Declined',
            value: 'declined',
          },
          {
            type: 'checkbox',
            name: 'awaiting-provider-decision',
            text: 'New',
            value: 'awaiting_provider_decision',
          },
          {
            type: 'checkbox',
            name: 'offer',
            text: 'Offered',
            value: 'offer',
          },
          {
            type: 'checkbox',
            name: 'rejected',
            text: 'Rejected',
            value: 'rejected',
          },
          {
            type: 'checkbox',
            name: 'withdrawn',
            text: 'Application withdrawn',
            value: 'withdrawn',
          },
          {
            type: 'checkbox',
            name: 'offer-withdrawn',
            text: 'Withdrawn by us',
            value: 'offer_withdrawn',
          },
        ],
      },
      {
        heading: 'provider',
        input_config: [
          {
            type: 'checkbox',
            name: 'somerset-scitt-consortium',
            text: 'Somerset SCITT consortium',
            value: '1',
          },
          {
            type: 'checkbox',
            name: 'the-beach-teaching-school',
            text: 'The Beach Teaching School',
            value: '2',
          },

        ],
      },
    ]
  end

  let(:params_for_current_state) do
    {
      sort_by: 'desc',
      sort_order: 'last-updated',
    }
  end

  it 'includes tags that match what has been selected for' do
    result = render_inline described_class.new(
      available_filters: available_filters,
      applied_filters: applied_filters_partial,
      params_for_current_state: params_for_current_state,
    )

    expect(result.css('.moj-filter-tags').text).to include('Accepted', 'New', 'Rejected', 'Application withdrawn', 'The Beach Teaching School')
    expect(result.css('.moj-filter-tags').text).not_to include('Declined', 'Conditions met', 'Somerset SCITT consortium')
  end

  it 'has a clear button when filters have been selected' do
    result = render_inline described_class.new(
      available_filters: available_filters,
      applied_filters: applied_filters_partial,
      params_for_current_state: params_for_current_state,
    )

    expect(result.text).to include('Clear')
  end

  it 'can return a full text of a applied_filters value from the available_filters' do
    filter_component = described_class.new(
      available_filters: available_filters,
      applied_filters: applied_filters_partial,
      params_for_current_state: params_for_current_state,
    )

    expect(filter_component.retrieve_tag_text('status', 'offer_withdrawn')).to eq('Withdrawn by us')
    expect(filter_component.retrieve_tag_text('provider', '2')).to eq('The Beach Teaching School')
  end

  it 'can create hash for a tag url that doesn\'t include that tag\'s params' do
    filter_component = described_class.new(
      available_filters: available_filters,
      applied_filters: applied_filters_partial,
      params_for_current_state: params_for_current_state,
    )

    hash = filter_component.build_tag_url_query_params(heading: 'status',
                                                       tag_value: 'withdrawn')

    expect(hash).to eq(applied_filters_partial_minus_withdrawn)
  end

  it 'can create a tag url that doesn\'t include that tag\'s values' do
    result = render_inline described_class.new(
      available_filters: available_filters,
      applied_filters: applied_filters_partial,
      params_for_current_state: params_for_current_state,
    )

    expect(result.css('#tag-rejected').attr('href').value).not_to include('rejected')
    expect(result.css('#tag-rejected').attr('href').value).to include('2')
    expect(result.css('#tag-rejected').attr('href').value).to include('awaiting_provider_decision')
    expect(result.css('#tag-rejected').attr('href').value).to include('offer')
    expect(result.css('#tag-rejected').attr('href').value).to include('pending_conditions')
    expect(result.css('#tag-rejected').attr('href').value).to include('withdrawn')
  end
end

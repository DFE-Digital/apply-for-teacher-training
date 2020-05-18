require 'rails_helper'

RSpec.describe ProviderInterface::FilterComponent do
  let(:path) { :provider_interface_applications_path }

  let(:applied_filters_partial) do
    {
      'status' => {
        'pending_conditions' => 'on',
        'awaiting_provider_decision' => 'on',
        'offer' => 'on',
        'rejected' => 'on',
        'withdrawn' => 'on',
      }, 'provider' => {
        '2' => 'on',
      }
    }
  end

  let(:applied_filters_partial_minus_withdrawn) do
    {
      'status' => {
        'pending_conditions' => 'on',
        'awaiting_provider_decision' => 'on',
        'offer' => 'on',
        'rejected' => 'on',
      }, 'provider' => {
        '2' => 'on',
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
            text: 'Accepted',
            name: 'pending_conditions',
          },
          {
            type: 'checkbox',
            text: 'Conditions met',
            name: 'recruited',
          },
          {
            type: 'checkbox',
            text: 'Declined',
            name: 'declined',
          },
          {
            type: 'checkbox',
            text: 'New',
            name: 'awaiting_provider_decision',
          },
          {
            type: 'checkbox',
            text: 'Offered',
            name: 'offer',
          },
          {
            type: 'checkbox',
            text: 'Rejected',
            name: 'rejected',
          },
          {
            type: 'checkbox',
            text: 'Application withdrawn',
            name: 'withdrawn',
          },
          {
            type: 'checkbox',
            text: 'Withdrawn by us',
            name: 'offer_withdrawn',
          },
        ],
      },
      {
        heading: 'provider',
        input_config: [
          {
            type: 'checkbox',
            text: 'Somerset SCITT consortium',
            name: '1',
          },
          {
            type: 'checkbox',
            text: 'The Beach Teaching School',
            name: '2',
          },

        ],
      },
    ]
  end

  let(:available_filters_only_one_provider) do
    [
      {
        heading: 'status',
        input_config: [
          {
            type: 'checkbox',
            text: 'Accepted',
            name: 'pending_conditions',
          },
          {
            type: 'checkbox',
            text: 'Withdrawn by us',
            name: 'offer_withdrawn',
          },
        ],
      },
      {
        heading: 'provider',
        input_config: [
          {
            type: 'checkbox',
            text: 'Somerset SCITT consortium',
            name: '1',
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

  it 'marks checkboxes as checked if they have already been pre-selected' do
    result = render_inline described_class.new(
      available_filters: available_filters,
      applied_filters: applied_filters_partial,
      params_for_current_state: params_for_current_state,
    )

    expect(result.css('#status-accepted').attr('checked').value).to eq('checked')
    expect(result.css('#status-recruited').attr('checked')).to eq(nil)
    expect(result.css('#status-declined').attr('checked')).to eq(nil)
    expect(result.css('#status-new').attr('checked').value).to eq('checked')
    expect(result.css('#status-rejected').attr('checked').value).to eq('checked')
    expect(result.css('#status-application-withdrawn').attr('checked').value).to eq('checked')
    expect(result.css('#provider-somerset-scitt-consortium').attr('checked')).to eq(nil)
    expect(result.css('#provider-the-beach-teaching-school').attr('checked').value).to eq('checked')
  end

  it 'on initial load all of the checkboxes are unchecked' do
    result = render_inline described_class.new(
      available_filters: available_filters,
      applied_filters: {},
      params_for_current_state: params_for_current_state,
    )

    expect(result.css('#status-accepted').attr('checked')).to eq(nil)
    expect(result.css('#status-recruited').attr('checked')).to eq(nil)
    expect(result.css('#status-declined').attr('checked')).to eq(nil)
    expect(result.css('#status-new').attr('checked')).to eq(nil)
    expect(result.css('#status-rejected').attr('checked')).to eq(nil)
    expect(result.css('#status-application-withdrawn').attr('checked')).to eq(nil)
    expect(result.css('#provider-somerset-scitt-consortium').attr('checked')).to eq(nil)
    expect(result.css('#provider-the-beach-teaching-school').attr('checked')).to eq(nil)
  end

  it 'when filters have been selected filters dialogue to appear' do
    result = render_inline described_class.new(
      available_filters: available_filters,
      applied_filters: applied_filters_partial,
      params_for_current_state: params_for_current_state,
    )

    expect(result.text).to include('Selected filters')
  end

  it 'selected filters dialogue should not appear if is nothing filtered for' do
    result = render_inline described_class.new(
      available_filters: available_filters,
      applied_filters: {},
      params_for_current_state: params_for_current_state,
    )

    expect(result.text).not_to include('Selected filters')
  end

  it 'does not render a filter if there is only one possible filter in a filter_group' do
    result = render_inline described_class.new(
      available_filters: available_filters_only_one_provider,
      applied_filters: {},
      params_for_current_state: params_for_current_state,
    )

    expect(result.to_html).not_to include('Provider')
    expect(result.to_html).to include('Status')
  end
end

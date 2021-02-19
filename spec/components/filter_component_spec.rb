require 'rails_helper'

RSpec.describe FilterComponent do
  let(:applied_filters) do
    ActionController::Parameters.new({ 'status' => %w[awaiting_provider_decision
                                                      pending_conditions
                                                      recruited
                                                      declined] })
  end

  let(:filters) do
    [{ type: :search, heading: 'Candidate’s name', value: '', name: 'candidate_name' },
     { type: :checkboxes,
       heading: 'Status',
       name: 'status',
       options: [{ value: 'awaiting_provider_decision', label: 'New', checked: false },
                 { value: 'offer', label: 'Offered', checked: false },
                 { value: 'pending_conditions', label: 'Accepted', checked: false },
                 { value: 'recruited', label: 'Conditions met', checked: false },
                 { value: 'rejected', label: 'Rejected', checked: false },
                 { value: 'declined', label: 'Declined', checked: true },
                 { value: 'withdrawn', label: 'Application withdrawn', checked: true },
                 { value: 'conditions_not_met', label: 'Conditions not met', checked: false },
                 { value: 'offer_withdrawn', label: 'Offer withdrawn', checked: false }] },
     { type: :checkboxes,
       heading: 'Provider',
       name: 'provider',
       options: [{ value: 1, label: 'Gorse SCITT', checked: false }] },
     { type: :checkboxes,
       heading: 'Accredited provider',
       name: 'accredited_provider',
       options: [{ value: 5, label: 'Coventry University', checked: nil }] }]
  end

  let(:provider_1) { create(:provider) }
  let(:provider_2) { create(:provider) }

  let(:current_provider_user) { build_stubbed(:provider_user) }

  it 'marks checkboxes as checked if they have already been pre-selected' do
    filter = ProviderInterface::ProviderApplicationsFilter.new(
      params: applied_filters,
      provider_user: current_provider_user,
      state_store: {},
    )

    result = render_inline described_class.new(filter: filter)

    expect(result.css('#status-awaiting_provider_decision').attr('checked').value).to eq('checked')
    expect(result.css('#status-offer').attr('checked')).to eq(nil)
    expect(result.css('#status-pending_conditions').attr('checked').value).to eq('checked')
    expect(result.css('#status-recruited').attr('checked').value).to eq('checked')
    expect(result.css('#status-rejected').attr('checked')).to eq(nil)
    expect(result.css('#status-declined').attr('checked').value).to eq('checked')
    expect(result.css('#status-withdrawn').attr('checked')).to eq(nil)
    expect(result.css('#status-conditions_not_met').attr('checked')).to eq(nil)
    expect(result.css('#status-offer_withdrawn').attr('checked')).to eq(nil)
  end

  it 'on initial load all of the checkboxes are unchecked' do
    filter = ProviderInterface::ProviderApplicationsFilter.new(
      params: ActionController::Parameters.new({}),
      provider_user: current_provider_user,
      state_store: {},
    )
    result = render_inline described_class.new(filter: filter)

    expect(result.css('#status-awaiting_provider_decision').attr('checked')).to eq(nil)
    expect(result.css('#status-offer').attr('checked')).to eq(nil)
    expect(result.css('#status-pending_conditions').attr('checked')).to eq(nil)
    expect(result.css('#status-recruited').attr('checked')).to eq(nil)
    expect(result.css('#status-rejected').attr('checked')).to eq(nil)
    expect(result.css('#status-declined').attr('checked')).to eq(nil)
    expect(result.css('#status-withdrawn').attr('checked')).to eq(nil)
    expect(result.css('#status-conditions_not_met').attr('checked')).to eq(nil)
    expect(result.css('#status-offer_withdrawn').attr('checked')).to eq(nil)
  end

  it 'when filters have been selected hidden text is displayed' do
    filter = ProviderInterface::ProviderApplicationsFilter.new(
      params: applied_filters,
      provider_user: current_provider_user,
      state_store: {},
    )

    result = render_inline described_class.new(filter: filter)

    expect(result.css('.govuk-visually-hidden').first.text).to include('Remove this filter')
  end

  it 'selected filters have hidden fields with remove links' do
    filter = ProviderInterface::ProviderApplicationsFilter.new(
      params: applied_filters,
      provider_user: current_provider_user,
      state_store: {},
    )

    result = render_inline described_class.new(filter: filter)

    expect(result.text).to include('Selected filters')
  end

  it 'selected filters dialogue should not appear if is nothing filtered for' do
    filter = ProviderInterface::ProviderApplicationsFilter.new(
      params: ActionController::Parameters.new({}),
      provider_user: current_provider_user,
      state_store: {},
    )

    result = render_inline described_class.new(filter: filter)

    expect(result.text).not_to include('Selected filters')
  end
end

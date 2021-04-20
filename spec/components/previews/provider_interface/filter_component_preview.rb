module ProviderInterface
  class FilterComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def default_view
      render_component_for(filter: filter_mock(filters: with_name_status_provider_and_accredited_provider))
    end

    def with_locations_view
      render_component_for(filter: filter_mock(filters: with_name_status_provider_accredited_provider_and_locations))
    end

  private

    def render_component_for(filter:)
      render FilterComponent.new(filter: filter)
    end

    def filter_mock(filters:)
      filter = Struct.new(:filters)
      filter.new(filters)
    end

    def with_name_status_provider_and_accredited_provider
      [{ type: :search, heading: 'Candidate’s name', value: '', name: 'candidate_name' },
       { type: :checkboxes,
         heading: 'Status',
         name: 'status',
         options: [{ value: 'awaiting_provider_decision', label: 'New', checked: false },
                   { value: 'offer', label: 'Offered', checked: false },
                   { value: 'pending_conditions', label: 'Accepted', checked: false },
                   { value: 'recruited', label: 'Conditions met', checked: false },
                   { value: 'enrolled', label: 'Enrolled', checked: false },
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

    def with_name_status_provider_accredited_provider_and_locations
      [{ type: :search, heading: 'Candidate’s name', value: '', name: 'candidate_name' },
       { type: :checkboxes,
         heading: 'Status',
         name: 'status',
         options: [{ value: 'awaiting_provider_decision', label: 'New', checked: false },
                   { value: 'offer', label: 'Offered', checked: false },
                   { value: 'pending_conditions', label: 'Accepted', checked: false },
                   { value: 'recruited', label: 'Conditions met', checked: false },
                   { value: 'enrolled', label: 'Enrolled', checked: false },
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
         options: [{ value: 5, label: 'Coventry University', checked: nil }] },
       { type: :checkboxes,
         heading: 'Locations for Gorse SCITT',
         name: 'location',
         options: [{ value: 1, label: 'Humbledown School', checked: false }, { value: 2, label: 'Twinswale Place', checked: false }] }]
    end
  end
end

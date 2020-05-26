module ProviderInterface
  class FilterComponentPreview < ViewComponent::Preview
    def fully_selected
      render_component_for(page_state: page_state_mock(filters: with_name_status_provider_and_accredited_provider))
    end

  private

    def render_component_for(page_state:)
      render ProviderInterface::FilterComponent.new(page_state: page_state)
    end

    def page_state_mock(filters:)
      page_state = Struct.new(:filters)
      page_state.new(filters)
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
                   { value: 'offer_withdrawn', label: 'Withdrawn by us', checked: false }] },
       { type: :checkboxes,
         heading: 'Provider',
         name: 'provider',
         options: [{ value: 1, label: 'Gorse SCITT', checked: false }] },
       { type: :checkboxes,
         heading: 'Accredited provider',
         name: 'accredited_provider',
         options: [{ value: 5, label: 'Coventry University', checked: nil }] }]
    end
  end
end

module ProviderInterface
  class FilterComponentPreview < ViewComponent::Preview
    def fully_selected
      render_component_for(available_filters: available_filters,
                           applied_filters: applied_filters_full,
                           params_for_current_state: params_for_current_state)
    end

    def partially_selected
      render_component_for(available_filters: available_filters,
                           applied_filters: applied_filters_partial,
                           params_for_current_state: params_for_current_state)
    end

    def empty
      render_component_for(available_filters: available_filters,
                           applied_filters: {},
                           params_for_current_state: params_for_current_state)
    end

  private

    def render_component_for(available_filters:, applied_filters:, params_for_current_state:)
      render ProviderInterface::FilterComponent.new(available_filters: available_filters,
                                                    applied_filters: applied_filters,
                                                    params_for_current_state: params_for_current_state)
    end

    def applied_filters_partial
      {
        'status' => {
          'pending-conditions' => 'pending_conditions',
          'awaiting-provider-decision' =>
          'awaiting_provider_decision',
            'offer' => 'offer',
            'rejected' => 'rejected',
            'withdrawn' => 'withdrawn',
        }, 'provider' => {
              'the-beach-teaching-school' => '2',
            }
      }
    end

    def applied_filters_full
      {
        'status' => {
          'pending-conditions' => 'pending_conditions',
          'recruited' => 'recruited',
          'declined' => 'declined',
          'awaiting-provider-decision' => 'awaiting_provider_decision',
          'offer' => 'offer',
          'rejected' => 'rejected',
          'withdrawn' => 'withdrawn',
          'offer-withdrawn' => 'offer_withdrawn',
        }, 'provider' => {
            'somerset-scitt-consortium' => '1',
            'the-beach-teaching-school' => '2',
          }
      }
    end

    def available_filters
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

    def params_for_current_state
      {
        sort_by: 'desc',
        sort_order: 'last-updated',
      }
    end
  end
end

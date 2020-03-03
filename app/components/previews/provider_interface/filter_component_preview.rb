module ProviderInterface
  class FilterComponentPreview < ActionView::Component::Preview
    def fully_selected
      render_component_for(path: :provider_interface_applications_path,
                           available_filters: available_filters,
                           preselected_filters: preselected_filters_full,
                           additional_params: additional_params)
    end

    def partially_selected
      render_component_for(path: :provider_interface_applications_path,
                           available_filters: available_filters,
                           preselected_filters: preselected_filters_partial,
                           additional_params: additional_params)
    end

    def empty
      render_component_for(path: :provider_interface_applications_path,
                           available_filters: available_filters,
                           preselected_filters: {},
                           additional_params: additional_params)
    end

  private

    def render_component_for(path:, available_filters:, preselected_filters:, additional_params:)
      render ProviderInterface::FilterComponent.new(path: path,
                                                    available_filters: available_filters,
                                                    preselected_filters: preselected_filters,
                                                    additional_params: additional_params)
    end

    def preselected_filters_partial
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

    def preselected_filters_full
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

    def additional_params
      {
        sort_by: 'desc',
        sort_order: 'last-updated',
      }
    end
  end
end

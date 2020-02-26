module ProviderInterface
  class FilterComponentPreview < ActionView::Component::Preview

    def offer_withdrawn
      render_component_for page_state:
    end

  private

    def render_component_for(page_state:)
      if !choices.empty?
        render ProviderInterface::FilterComponent.new(page_state: choices.order('RANDOM()').first)
      else
        render template: 'support_interface/docs/missing_test_data'
      end
    end
  end
end


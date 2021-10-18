class ServiceUnavailableComponentPreview < ViewComponent::Preview
  layout 'layouts/error'

  def service_unavailable_page
    render ServiceUnavailableComponent.new
  end
end

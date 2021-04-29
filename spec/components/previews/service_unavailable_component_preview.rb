class ServiceUnavailableComponentPreview < ViewComponent::Preview
  def service_unavailable_page
    render ServiceUnavailableComponent.new
  end
end

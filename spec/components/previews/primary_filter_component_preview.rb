class PrimaryFilterComponentPreview < ViewComponent::Preview
  def default
    render PrimaryFilterComponent.new(filters: [], primary_filter: { name: 'filter' }, secondary_filters: [])
  end
end

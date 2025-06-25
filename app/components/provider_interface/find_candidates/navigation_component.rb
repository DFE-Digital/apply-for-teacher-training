class ProviderInterface::FindCandidates::NavigationComponent < ViewComponent::Base
  def initialize(selected_tab)
    @selected_tab = selected_tab
  end

  def items
    [
      all_candidates_item, invited_item
    ]
  end

  def all_candidates_item
    {
      current: @selected_tab == :all,
      name: t('.all'),
      url: provider_interface_candidate_pool_candidates_path,
    }
  end

  def invited_item
    {
      current: @selected_tab == :invited,
      name: t('.invited'),
      url: provider_interface_candidate_pool_invites_path,
    }
  end

  def call
    render TabNavigationComponent.new(items:)
  end
end

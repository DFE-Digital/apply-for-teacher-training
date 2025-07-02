class ProviderInterface::FindCandidates::TabNavigationComponent < ViewComponent::Base
  def initialize(selected_tab)
    @selected_tab = selected_tab
  end

  def items
    [all_candidates, not_seen_candidates_item, invited]
  end

  def all_candidates
    {
      current: @selected_tab == :all,
      name: t('.all'),
      url: provider_interface_candidate_pool_candidates_path,
    }
  end

  def invited
    {
      current: @selected_tab == :invited,
      name: t('.invited'),
      url: provider_interface_candidate_pool_invites_path,
    }
  end

  def not_seen_candidates_item
    {
      current: @selected_tab == :not_seen,
      name: t('.not_seen'),
      url: provider_interface_candidate_pool_not_seen_index_path,
    }
  end

  def call
    render TabNavigationComponent.new(items:)
  end
end

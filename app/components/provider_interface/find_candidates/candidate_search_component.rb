class ProviderInterface::FindCandidates::CandidateSearchComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :filter

  def initialize(filter:)
    @filter = filter
  end

private

  def path_to_remove_candidate_id_filter
    applied_filters = filter.applied_filters.clone.with_indifferent_access
    applied_filters.delete(:candidate_id)
    applied_filters.delete(:candidate_search)
    applied_filters[:apply_filters] = true

    to_query(applied_filters)
  end

  def to_query(params)
    "?#{params.to_query}"
  end
end

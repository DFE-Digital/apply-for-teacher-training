class ProviderUserFilter < ApplicationRecord
  belongs_to :provider_user

  enum :kind, {
    find_candidates_all: 'find_candidates_all',
    find_candidates_not_seen: 'find_candidates_not_seen',
    find_candidates_invited: 'find_candidates_invited',
  }
end

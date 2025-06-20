class ProviderPoolAction < ApplicationRecord
  belongs_to :application_form
  belongs_to :provider_user, foreign_key: :actioned_by_id

  enum :status, {
    viewed: 'viewed',
  }, prefix: true
end

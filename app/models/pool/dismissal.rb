class Pool::Dismissal < ApplicationRecord
  belongs_to :candidate
  belongs_to :provider
  belongs_to :dismissed_by, class_name: 'ProviderUser'
end

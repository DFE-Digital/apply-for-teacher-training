class DfESigninSession < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :impersonated_provider_user, optional: true
end

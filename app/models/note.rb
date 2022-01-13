class Note < ApplicationRecord
  belongs_to :application_choice, touch: true
  belongs_to :provider_user
  belongs_to :user, polymorphic: true
end

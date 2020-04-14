class Note < ApplicationRecord
  belongs_to :application_choice
  belongs_to :provider_user
end

class Note < ApplicationRecord
  self.ignored_columns = %w[subject]

  belongs_to :application_choice, touch: true
  belongs_to :provider_user
end

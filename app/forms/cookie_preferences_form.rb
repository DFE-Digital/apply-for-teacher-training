class CookiePreferencesForm
  include ActiveModel::Model

  attr_accessor :consent

  validates :consent, inclusion: { in: %w[yes no] }
end

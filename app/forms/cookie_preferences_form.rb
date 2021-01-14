class CookiePreferencesForm
  include ActiveModel::Model

  attr_accessor :consent

  validates :consent, inclusion: { in: %w[yes no] }

  def initialize(consent:)
    @consent = consent
  end
end

class OfferCondition < ApplicationRecord
  STANDARD_CONDITIONS = ['Fitness to train to teach check', 'Disclosure and Barring Service (DBS) check', 'Satisfactory references'].freeze

  belongs_to :offer, touch: true
  has_one :application_choice, through: :offer

  audited associated_with: :application_choice

  enum :status, {
    pending: 'pending',
    met: 'met',
    unmet: 'unmet',
  }

  validates :status, presence: true
  validates :type, presence: true

  def standard_condition?
    STANDARD_CONDITIONS.include?(text)
  end

  def self.detail(key)
    define_method(key) do
      self.details ||= {}
      ActiveSupport::HashWithIndifferentAccess.new(details)[key]
    end

    define_method("#{key}=") do |value|
      self.details ||= {}
      details[key] = value
    end
  end
end

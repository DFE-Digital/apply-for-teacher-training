class ApplicationChoice < ApplicationRecord
  before_create :set_id
  belongs_to :application_form, touch: true

  enum status: {
    application_complete: 'application_complete',
    conditional_offer: 'conditional_offer',
    unconditional_offer: 'unconditional_offer',
    recruited: 'recruited',
    enrolled: 'enrolled',
    rejected: 'rejected',
  }

private

  def generate_alphanumeric_id
    SecureRandom.hex(5)
  end

  def set_id
    alphanumeric_id = ''
    loop do
      alphanumeric_id = generate_alphanumeric_id
      break unless ApplicationChoice.exists?(id: alphanumeric_id)
    end
    self.id = alphanumeric_id
  end
end

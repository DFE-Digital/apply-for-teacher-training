class ApplicationChoice < ApplicationRecord
  before_create :set_id
  before_create :set_initial_status
  belongs_to :application_form, touch: true
  belongs_to :course
  has_one :provider, through: :course

  enum status: {
    unsubmitted: 'unsubmitted',
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

  def set_initial_status
    self.status ||= 'unsubmitted'
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

class ApplicationChoice < ApplicationRecord
  belongs_to :application_form, touch: true

  enum status: {
    application_complete: 'application_complete',
    conditional_offer: 'conditional_offer',
    unconditional_offer: 'unconditional_offer',
    enrolled: 'enrolled',
  }
end

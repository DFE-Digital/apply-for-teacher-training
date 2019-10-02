# Candidates can apply to multiple courses via a single Application Form.
class ApplicationChoice < ApplicationRecord
  belongs_to :application_form, touch: true
  enum status: {
    application_complete: 'application_complete',
    conditional_offer: 'conditional_offer',
  }
end

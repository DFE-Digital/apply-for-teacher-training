# Candidates can apply to multiple courses via a single Application Form.
class ApplicationChoice < ApplicationRecord
  belongs_to :application_form, touch: true
  enum status: { application_complete: 0, conditional_offer: 1 }
end

# Candidates can apply to multiple courses via a single Application Form.
class ApplicationChoice < ApplicationRecord
  belongs_to :application_form
end

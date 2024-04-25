class ApplicationFeedback < ApplicationRecord
  self.table_name = 'application_feedback'
  belongs_to :application_form, touch: true
  has_one :candidate, through: :application_form
end

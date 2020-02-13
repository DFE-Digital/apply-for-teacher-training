class ApplicationWorkHistoryBreak < ApplicationRecord
  belongs_to :application_form, touch: true

  audited associated_with: :application_form

  def length
    (end_date.year * 12 + end_date.month) - (start_date.year * 12 + start_date.month) - 1
  end
end

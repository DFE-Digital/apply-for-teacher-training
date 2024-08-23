class ApplicationWorkHistoryBreak < ApplicationRecord
  self.ignored_columns += %w[application_form_id]

  belongs_to :breakable, polymorphic: true, touch: true

  audited associated_with: :breakable

  def application_form
    breakable if breakable_type == 'ApplicationForm'
  end

  def length
    ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month) - 1
  end
end

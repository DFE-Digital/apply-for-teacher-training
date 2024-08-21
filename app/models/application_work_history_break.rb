class ApplicationWorkHistoryBreak < ApplicationRecord
  belongs_to :breakable, polymorphic: true, touch: true

  before_save -> { self.application_form_id = breakable_id }, if: -> { application_form_id.nil? }

  audited associated_with: :breakable

  after_commit do
    if application_form
      breakable.touch_choices
    end
  end

  def application_form
    breakable if breakable_type == 'ApplicationForm'
  end

  def length
    ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month) - 1
  end
end

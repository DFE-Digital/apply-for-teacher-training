class ApplicationWorkHistoryBreak < ApplicationRecord
  include TouchApplicationChoices

  belongs_to :application_form, touch: true, optional: true
  belongs_to :breakable, polymorphic: true

  before_save -> { self.application_form_id = breakable_id }, if: -> { application_form_id.nil? }

  audited associated_with: :application_form

  def application_form=(value)
    super
    self.breakable = value
  end

  def length
    ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month) - 1
  end
end

class ApplicationWorkHistoryBreak < ApplicationRecord
  include TouchApplicationChoices

  belongs_to :application_form, touch: true
  belongs_to :breakable, polymorphic: true, optional: true

  before_save -> { self.breakable = application_form }, if: -> { breakable.nil? }

  audited associated_with: :application_form

  def length
    ((end_date.year * 12) + end_date.month) - ((start_date.year * 12) + start_date.month) - 1
  end
end

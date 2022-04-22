class Interview < ApplicationRecord
  include Discard::Model

  self.discard_column = :cancelled_at
  alias cancelled? discarded?

  audited associated_with: :application_choice

  belongs_to :application_choice, touch: true
  belongs_to :provider

  validates :date_and_time, presence: true

  delegate :current_course, to: :application_choice

  scope :for_application_choices, ->(application_choices) { joins(:application_choice).merge(application_choices).kept }
  scope :upcoming, -> { where('date_and_time >= ?', Time.zone.now.beginning_of_day) }
  scope :past, -> { where('date_and_time < ?', Time.zone.now.beginning_of_day) }
  scope :upcoming_not_today, -> { where('date_and_time > ?', Time.zone.now.end_of_day) }

  def date
    date_and_time.to_fs(:govuk_date)
  end

  def time
    date_and_time.to_fs(:govuk_time)
  end
end

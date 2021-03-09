class Interview < ApplicationRecord
  include Discard::Model

  self.discard_column = :cancelled_at
  alias_method :cancelled?, :discarded?

  audited associated_with: :application_choice

  belongs_to :application_choice
  belongs_to :provider

  validates :application_choice, :provider, :date_and_time, presence: true

  delegate :offered_course, to: :application_choice

  def self.for_application_choices(application_choices)
    with(application_choices: application_choices)
      .joins('INNER JOIN application_choices ON interviews.application_choice_id = application_choices.id')
      .kept
  end

  scope :upcoming, -> { where('date_and_time >= ?', Time.zone.now.beginning_of_day) }
  scope :past, -> { where('date_and_time < ?', Time.zone.now.beginning_of_day) }

  def date
    date_and_time.to_s(:govuk_date)
  end
end

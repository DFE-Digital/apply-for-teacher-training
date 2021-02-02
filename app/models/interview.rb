class Interview < ApplicationRecord
  include Discard::Model

  self.discard_column = :cancelled_at
  alias_method :cancelled?, :discarded?

  audited associated_with: :application_choice

  belongs_to :application_choice
  belongs_to :provider

  validates :application_choice, :provider, :date_and_time, presence: true

  delegate :offered_course, to: :application_choice
end

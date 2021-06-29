class Offer < ApplicationRecord
  belongs_to :application_choice
  has_many :conditions, -> { order('created_at ASC') }, class_name: 'OfferCondition', dependent: :destroy

  has_one :course_option, through: :application_choice, source: :current_course_option

  delegate :course, :site, :provider, :accredited_provider, to: :course_option
  delegate :offered_at, to: :application_choice

  def unconditional?
    conditions.none?
  end

  def non_pending_conditions?
    conditions.not_pending.any?
  end

  def conditions_text
    conditions.pluck(:text)
  end
end

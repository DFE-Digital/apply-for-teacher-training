class Offer < ApplicationRecord
  belongs_to :application_choice, touch: true
  has_many :conditions, -> { order(:created_at) }, class_name: 'OfferCondition', dependent: :destroy
  has_many :text_conditions, -> { where(type: 'TextCondition').order(:created_at) }, class_name: 'TextCondition', dependent: :destroy
  has_many :ske_conditions, -> { where(type: 'SkeCondition').order(:created_at) }, class_name: 'SkeCondition', dependent: :destroy
  has_one :reference_condition, -> { where(type: 'ReferenceCondition').order(:created_at) }, class_name: 'ReferenceCondition', dependent: :destroy
  has_many :all_conditions, -> { order(:created_at) }, class_name: 'OfferCondition', dependent: :destroy

  has_one :course_option, through: :application_choice, source: :current_course_option

  delegate :course, :site, :study_mode, :provider, :accredited_provider, to: :course_option
  delegate :offered_at, to: :application_choice

  def unconditional?
    conditions.none?
  end

  def non_structured_conditions_text
    text_conditions.map(&:text)
  end

  def all_conditions_text
    conditions.map(&:text)
  end

  def all_conditions_met?
    conditions.all?(&:met?)
  end
end

class InterviewValidations
  include ActiveModel::Model

  APPLICATION_STATES_ALLOWING_CHANGES = ApplicationStateChange::INTERVIEWABLE_STATES.map(&:to_s).freeze

  attr_reader :interview, :today

  delegate :current_course, to: :application_choice
  delegate :application_choice, :provider, :date_and_time, :location,
           :additional_details, :cancellation_reason, to: :interview

  validates :date_and_time, :application_choice, :provider, :location, presence: true, on: %i[create update cancel]
  validates :location, :additional_details, length: { maximum: 10240 }, on: %i[create update]
  validates :cancellation_reason, presence: true, length: { maximum: 10240 }, on: :cancel

  validate :require_training_or_ratifying_provider, on: %i[create update], if: -> { application_choice }
  validate :create_interview_in_the_past, on: :create
  validate :updates_to_date_and_time, on: :update

  def initialize(interview:)
    @interview = interview
    @today = Time.zone.now.beginning_of_day
  end

  def rbd_date
    @rbd_date ||= application_choice&.reject_by_default_at
  end

  def require_training_or_ratifying_provider
    ratifying = current_course.accredited_provider
    ratifying_provider_check = ratifying ? provider == ratifying : false

    unless provider == current_course.provider || ratifying_provider_check || provider.blank?
      errors.add :provider, :training_or_ratifying_only
    end
  end

  def create_interview_in_the_past
    if date_and_time && date_and_time < today
      errors.add :date_and_time, :in_the_past
    end
  end

  def updates_to_date_and_time
    old_date = interview.date_and_time_change&.first
    new_date = interview.date_and_time_change&.second

    if old_date.present? && new_date.present?
      if new_date < today && old_date >= today
        errors.add :date_and_time, :moving_interview_to_the_past
      elsif new_date < today
        errors.add :date_and_time, :in_the_past
      end
    end
  end
end

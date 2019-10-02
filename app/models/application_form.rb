# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  belongs_to :candidate
  belongs_to :application_stage
  has_many :application_choices

  before_validation :initialize_application_stage

  scope :most_recently_created, -> { order('created_at DESC').first }

  validates :application_choices, length: { minimum: 1 }, on: :submit
  validate :application_choices_does_not_exceed_limit, on: :submit
  validate :application_submission_is_within_stage_time_limit, on: :submit
  validate :all_choices_are_open, on: :submit

  def add_course_choice(course_choice)
    application_choices.create!(course_choice: course_choice)
  end

  def submit
    if self.validate(:submit)
      application_choices.map(&:submit)
    end
  end

private

  def initialize_application_stage
    stage = candidate.application_forms.any? ? Apply2Stage : Apply1Stage
    self.application_stage ||= stage.applicable_at(Time.now)
  end

  def application_choices_does_not_exceed_limit
    if application_choices.size > application_stage.simultaneous_applications_limit
      errors.add(:application_choices, "cannot exceed #{application_stage.simultaneous_applications_limit}")
    end
  end

  def application_submission_is_within_stage_time_limit
    if Time.now < application_stage.from_time
      errors.add(:base, "form submitted before #{application_stage} is open")
    elsif Time.now > application_stage.to_time
      errors.add(:base, "form submitted after #{application_stage} is closed")
    end
  end

  def all_choices_are_open
    unless application_choices.all?(&:open)
      errors.add(:application_choices, 'must all be open')
    end
  end
end

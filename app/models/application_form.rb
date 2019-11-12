# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  belongs_to :candidate
  has_many :application_choices
  has_many :application_work_experiences
  has_many :application_volunteering_experiences
  has_many :application_qualifications
  has_many :references

  MINIMUM_COMPLETE_REFERENCES = 2

  after_save -> {
    application_choices.update_all(updated_at: Time.zone.now)
  }

  attr_accessor :course_choices_present
  validates :course_choices_completed, acceptance: true, if: -> { course_choices_present }

  def submitted?
    application_choices.any? && !application_choices.first.unsubmitted?
  end

  def references_complete?
    references.select(&:complete?).count == MINIMUM_COMPLETE_REFERENCES
  end

  def qualification_in_subject(level, subject)
    application_qualifications
      .where(level: level, subject: subject)
      .order(created_at: 'asc')
      .first
  end

  audited
end

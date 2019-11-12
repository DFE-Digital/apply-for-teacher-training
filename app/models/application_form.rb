# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  belongs_to :candidate
  has_many :application_choices
  has_many :application_work_experiences
  has_many :application_volunteering_experiences
  has_many :application_qualifications
  has_many :references

  MINIMUM_REFERENCES = 2

  def submitted?
    application_choices.any? && !application_choices.first.unsubmitted?
  end

  def references_complete?
    references.select(&:complete?).count >= MINIMUM_REFERENCES
  end

  def qualification_in_subject(level, subject)
    application_qualifications
      .where(level: level, subject: subject)
      .order(created_at: 'asc')
      .first
  end

  audited
end

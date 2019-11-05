# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  belongs_to :candidate
  has_many :application_choices
  has_many :application_work_experiences
  has_many :application_volunteering_experiences
  has_many :application_qualifications
  has_many :references

  def submitted?
    application_choices.any? && !application_choices.first.unsubmitted?
  end

  def references_complete?
    references.any? && references.all?(&:complete?)
  end

  audited
end

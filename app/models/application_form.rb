# The Application Form is filled in and submitted by the Candidate. Candidates
# can initially apply to 3 different courses, represented by an Application Choice.
class ApplicationForm < ApplicationRecord
  belongs_to :candidate
  belongs_to :application_stage
  has_many :application_choices

  before_validation :initialize_application_stage

  scope :most_recently_created, -> { order("created_at DESC").first }

private

  def initialize_application_stage
    self.application_stage ||= Apply1Stage.applicable_at(Time.now)
  end
end

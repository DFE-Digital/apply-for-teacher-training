# Candidates can apply to multiple courses via a single Application Form.
class ApplicationChoice < ApplicationRecord
  belongs_to :application_form
  belongs_to :course_choice

  def open
    course_choice&.open
  end

  def submit
    # TODO: implement state change here
  end
end

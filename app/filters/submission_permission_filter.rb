class SubmissionPermissionFilter
  attr_reader :controller

  def self.before(controller)
    new(controller).call
  end

  delegate :redirect_to,
           :current_candidate,
           :candidate_interface_course_choices_blocked_submissions_path,
           to: :controller

  def initialize(controller)
    @controller = controller
  end

  def call
    redirect_to candidate_interface_course_choices_blocked_submissions_path if current_candidate.submission_blocked?
  end
end

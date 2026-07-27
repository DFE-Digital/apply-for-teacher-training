class NonDisclosureTraineeWithdrawalWorker < ApplicationJob
  queue_as :default

  retry_on StandardError, attempts: 3

  def perform(candidate_id)
    return unless HostingEnvironment.production? || HostingEnvironment.qa? || HostingEnvironment.test_environment?

    candidate = Candidate.find(candidate_id)
    GeneratePossiblePreviousTeacherTraining.new(candidate).call
  end
end

class NonDisclosureTraineeWithdrawalWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform(candidate_id)
    return unless HostingEnvironment.production? || HostingEnvironment.qa? || HostingEnvironment.test_environment?

    candidate = Candidate.find(candidate_id)
    GeneratePossiblePreviousTeacherTraining.new(candidate).call
  end
end

class NonDisclosureTraineeWithdrawalWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: :default

  def perform(candidate_id)
    candidate = Candidate.find(candidate_id)
    GeneratePossiblePreviousTeacherTraining.new(candidate).call
  end
end

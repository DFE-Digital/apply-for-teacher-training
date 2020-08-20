class RejectAwaitingReferencesCourseChoicesWorker
  include Sidekiq::Worker

  def self.perform
    CandidateInterface::GetPreviousCyclesAwaitingReferencesCourseChoices.call&.each do |application_choice|
      CandidateInterface::RejectAwaitingReferencesApplication.call(application_choice)
    end
  end
end

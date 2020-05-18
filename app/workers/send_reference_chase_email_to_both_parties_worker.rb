class SendReferenceChaseEmailToBothPartiesWorker
  include Sidekiq::Worker

  def perform
    GetReferencesToChase.call.each do |reference|
      SendReferenceChaseEmailToRefereeAndCandidate.call(application_form: reference.application_form, reference: reference)
    end
  end
end

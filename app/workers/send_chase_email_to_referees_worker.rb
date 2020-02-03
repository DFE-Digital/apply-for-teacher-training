class SendChaseEmailToRefereesWorker
  include Sidekiq::Worker

  def perform
    GetRefereesToChase.call.each do |reference|
      SendChaseEmailToRefereeAndCandidate.call(application_form: reference.application_form, reference: reference)
    end
  end
end

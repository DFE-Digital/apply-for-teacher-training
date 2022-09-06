# This worker will be scheduled to run nightly
class RejectApplicationsByDefault
  def call
    GetApplicationChoicesReadyToRejectByDefault.call.each do |application_choice|
      RejectApplicationByDefault.new(application_choice:).call
    end
  end
end

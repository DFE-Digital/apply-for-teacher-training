class Adviser::Tracking
  attr_reader :current_user, :request

  def initialize(current_user, request)
    @current_user = current_user
    @request = request
  end

  def candidate_offered_adviser
    event = DfE::Analytics::Event.new
      .with_type(:candidate_offered_adviser)
      .with_user(current_user)
      .with_request_details(request)

    DfE::Analytics::SendEvents.do([event])
  end

  def candidate_signed_up_for_adviser
    event = DfE::Analytics::Event.new
      .with_type(:candidate_signed_up_for_adviser)
      .with_user(current_user)
      .with_request_details(request)

    DfE::Analytics::SendEvents.do([event])
  end
end

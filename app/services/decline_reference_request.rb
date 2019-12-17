class DeclineReferenceRequest
  def initialize(referee:)
    @referee = referee
  end

  def save!
    @referee.rejected_reference_request = true
    @referee.save
  end
end

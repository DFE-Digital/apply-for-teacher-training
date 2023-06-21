class RejectApplicationsByDefault
  def call
    GetStaleApplicationChoices.call.each do |application_choice|
      RejectApplicationByDefault.new(application_choice:).call
    end
  end
end

class ConfirmEnrolment
  Response = Struct.new(:successful?, :application_choice)

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    @application_choice.update_attribute(:status, :enrolled)

    Response.new(true, @application_choice)
  end
end

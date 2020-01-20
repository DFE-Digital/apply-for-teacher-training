class RequestReference
  attr_accessor :referee_params, :referee, :application_form

  def initialize(referee_params:, application_form:)
    self.referee_params = referee_params
    self.application_form = application_form
  end

  def call
    @referee = application_form.application_references.build(referee_params)
    @referee.save
  end
end

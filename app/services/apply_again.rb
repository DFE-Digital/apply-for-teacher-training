class ApplyAgain
  def initialize(application_form)
    @application_form = application_form
  end

  def call
    DuplicateApplication.new(application_form, target_phase: 'apply_2').duplicate
  end
end

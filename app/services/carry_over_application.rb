class CarryOverApplication
  def initialize(application_form)
    @application_form = application_form
  end

  def call
    # TODO: Raise error if we attempt to carry over an application from current cycle?

    DuplicateApplication.new(@application_form, target_phase: 'apply_1').duplicate
  end
end

class CarryOverApplication
  NEW_CYCLE = 2021

  def initialize(application_form)
    @application_form = application_form
  end

  def call
    return if @application_form.cycle == NEW_CYCLE

    new_application = DuplicateApplication.new(@application_form, target_phase: 'apply_1').duplicate
    new_application.update(cycle: NEW_CYCLE)
  end
end

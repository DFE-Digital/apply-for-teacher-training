class ApplyAgain
  def initialize(application_form)
    @application_form = application_form
  end

  def call
    if @application_form.ended_without_success?
      DuplicateApplication.new(@application_form, target_phase: 'apply_2').duplicate
    else
      false
    end
  end
end

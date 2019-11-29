class CheckScienceGcseIsNeeded
  class << self
    def call(application_form)
      application_form.application_choices.any? do |application_choice|
        application_choice.course_option.course.primary_course?
      end
    end
  end
end

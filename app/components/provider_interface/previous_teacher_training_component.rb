module ProviderInterface
  class PreviousTeacherTrainingComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form
    def initialize(application_form:)
      @application_form = application_form
    end

    def previous_teacher_trainings
      @previous_teacher_trainings ||= application_form.previous_teacher_trainings.published
    end

    def render?
      previous_teacher_trainings.any?
    end
  end
end

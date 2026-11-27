module ProviderInterface
  class PreviousTeacherTrainingComponent < ApplicationComponent
    include ViewHelper

    attr_reader :application_form, :current_user

    def initialize(application_form:, current_user:)
      @application_form = application_form
      @current_user = current_user
    end

    def previous_teacher_trainings
      @previous_teacher_trainings ||= application_form.previous_teacher_trainings.published
    end

    def render?
      previous_teacher_trainings.any?
    end
  end
end

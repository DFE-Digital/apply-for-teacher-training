module SupportInterface
  class ChangeCourseForm
    include ActiveModel::Model
    attr_accessor :change_type, :application_form

    validates_presence_of :change_type

    def can_add_course?
      application_form.application_choices.count < 3
    end
  end
end

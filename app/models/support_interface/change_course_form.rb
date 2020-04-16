module SupportInterface
  class ChangeCourseForm
    include ActiveModel::Model
    attr_accessor :change_type, :application_form

    validates_presence_of :change_type
  end
end

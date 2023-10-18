module SupportInterface
  class ScienceGcseForm
    include ActiveModel::Model
    attr_accessor :application_form

    def self.build_from_qualification(qualification)
      new(
        application_form: qualification.application_form,
      )
    end
  end
end

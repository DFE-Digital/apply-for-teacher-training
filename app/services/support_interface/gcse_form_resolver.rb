module SupportInterface
  class GcseFormResolver
    def initialize(application_qualification)
      @application_qualification = application_qualification
    end

    def call
      case @application_qualification.subject
      when 'english'
        EnglishGcseForm
      when 'maths'
        MathGcseForm
      else
        ScienceGcseForm
      end
    end
  end
end

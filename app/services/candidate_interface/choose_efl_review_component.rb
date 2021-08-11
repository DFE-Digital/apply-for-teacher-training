module CandidateInterface
  class ChooseEflReviewComponent
    def self.call(english_proficiency, return_to_application_review: false)
      new(english_proficiency, return_to_application_review: return_to_application_review).call
    end

    attr_reader :english_proficiency

    def initialize(english_proficiency, return_to_application_review: false)
      @english_proficiency = english_proficiency
      @return_to_application_review = return_to_application_review
    end

    def call
      if !english_proficiency.has_qualification?
        return EnglishForeignLanguage::NoEflQualificationReviewComponent.new(english_proficiency, component_params)
      end

      qualification = english_proficiency.efl_qualification
      case english_proficiency.efl_qualification_type
      when 'IeltsQualification'
        EnglishForeignLanguage::IeltsReviewComponent.new(qualification, component_params)
      when 'ToeflQualification'
        EnglishForeignLanguage::ToeflReviewComponent.new(qualification, component_params)
      when 'OtherEflQualification'
        EnglishForeignLanguage::OtherEflQualificationReviewComponent.new(qualification, component_params)
      end
    end

  private

    def component_params
      { return_to_application_review: @return_to_application_review }
    end
  end
end

module CandidateInterface
  class ChooseEflReviewComponent
    def self.call(english_proficiency)
      new(english_proficiency).call
    end

    attr_reader :english_proficiency

    def initialize(english_proficiency)
      @english_proficiency = english_proficiency
    end

    def call
      if !english_proficiency.has_qualification?
        return NoEflQualificationReviewComponent.new(english_proficiency)
      end

      qualification = english_proficiency.efl_qualification
      case english_proficiency.efl_qualification_type
      when 'IeltsQualification'
        IeltsReviewComponent.new(qualification)
      when 'ToeflQualification'
        ToeflReviewComponent.new(qualification)
      end
    end
  end
end

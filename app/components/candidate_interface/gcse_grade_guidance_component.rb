module CandidateInterface
  class GcseGradeGuidanceComponent < ApplicationComponent
    def initialize(subject, qualification_type)
      @subject = subject
      @qualification_type = qualification_type
    end

  private

    def english?
      @subject == 'english'
    end

    def science?
      @subject == 'science'
    end

    def gcse?
      @qualification_type == 'gcse'
    end

    def gce_o_level?
      @qualification_type == 'gce_o_level'
    end

    def scottish_national_5?
      @qualification_type == 'scottish_national_5'
    end

    def other_uk?
      @qualification_type == 'other_uk'
    end
  end
end

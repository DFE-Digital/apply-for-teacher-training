module VendorAPI
  class ReferenceDataController < VendorAPIController
    def gcse_subjects
      render json: { data: GCSE_SUBJECTS }
    end

    def a_and_as_level_subjects
      render json: { data: A_AND_AS_LEVEL_SUBJECTS }
    end

    def gcse_grades
      render json: { data: ALL_GCSE_GRADES }
    end

    def a_and_as_level_grades
      render json: { data: A_LEVEL_GRADES | AS_LEVEL_GRADES }
    end
  end
end

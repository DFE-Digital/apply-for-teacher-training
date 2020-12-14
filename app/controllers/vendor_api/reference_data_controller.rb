module VendorAPI
  class ReferenceDataController < VendorAPIController
    def gcse_subjects
      render json: { data: GCSE_SUBJECTS }
    end

    def a_and_as_level_subjects
      render json: { data: A_AND_AS_LEVEL_SUBJECTS }
    end
  end
end

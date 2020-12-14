module VendorAPI
  class ReferenceDataController < VendorAPIController
    def gcse_subjects
      render json: { data: GCSE_SUBJECTS }
    end
  end
end

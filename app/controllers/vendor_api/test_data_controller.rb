module VendorApi
  class TestDataController < VendorApiController
    def regenerate
      GenerateTestData.new.generate([params[:count].to_i, 100].min)
      render json: { data: { message: 'OK, regenerated the test data' } }
    end
  end
end

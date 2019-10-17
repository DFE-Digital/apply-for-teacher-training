module VendorApi
  class TestDataController < VendorApiController
    def regenerate
      GenerateTestData.new([params[:count].to_i, 100].min, current_provider).generate
      render json: { data: { message: 'OK, regenerated the test data' } }
    end
  end
end

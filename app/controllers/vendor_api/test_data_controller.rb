module VendorApi
  class TestDataController < VendorApiController
    before_action :check_this_is_a_test_environment

    def regenerate
      GenerateTestData.new([params[:count].to_i, 100].min, current_provider).generate
      render json: { data: { message: 'OK, regenerated the test data' } }
    end

  private

    def check_this_is_a_test_environment
      if HostingEnvironment.production?
        render status: 400, json: { data: { message: 'Sorry, you can only generate test data in test environments' } }
      end
    end
  end
end

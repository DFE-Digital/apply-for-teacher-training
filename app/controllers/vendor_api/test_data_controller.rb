module VendorApi
  class TestDataController < VendorApiController
    before_action :check_this_is_a_test_environment

    MAX_COUNT = 100
    DEFAULT_COUNT = 100

    def regenerate
      GenerateTestData.new(count_param, current_provider).generate
      render json: { data: { message: 'OK, regenerated the test data' } }
    end

  private

    def check_this_is_a_test_environment
      if HostingEnvironment.production?
        render status: 400, json: { data: { message: 'Sorry, you can only generate test data in test environments' } }
      end
    end

    def count_param
      [(params[:count] || DEFAULT_COUNT).to_i, MAX_COUNT].min
    end
  end
end

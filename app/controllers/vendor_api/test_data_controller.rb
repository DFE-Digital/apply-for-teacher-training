module VendorApi
  class TestDataController < VendorApiController
    before_action :check_this_is_a_test_environment
    before_action :feature_flag_new_endpoints, only: %i[generate clear!]

    MAX_COUNT = 100
    DEFAULT_COUNT = 100

    MAX_COURSES_COUNT = 3
    DEFAULT_COURSES_COUNT = 1

    def regenerate
      GenerateTestData.new(count_param, current_provider).generate
      render json: { data: { message: 'OK, regenerated the test data' } }
    end

    def generate
      application_choices = (1..count_param).flat_map do
        states = [:awaiting_provider_decision] * courses_per_application_param
        TestApplications.create_application states: states, courses_to_apply_to: current_provider.courses
      end

      render json: { data: { ids: application_choices.map { |ac| ac.id.to_s } } }
    end

    def clear!
      current_provider.application_choices.map(&:delete)

      render json: { data: { message: 'Applications cleared' } }
    end

  private

    def feature_flag_new_endpoints
      if !FeatureFlag.active?('new_test_data_endpoints')
        render json: {}, status: :not_found
      end
    end

    def check_this_is_a_test_environment
      if HostingEnvironment.production?
        render status: :bad_request, json: { data: { message: 'Sorry, you can only generate test data in test environments' } }
      end
    end

    def count_param
      [(params[:count] || DEFAULT_COUNT).to_i, MAX_COUNT].min
    end

    def courses_per_application_param
      [(params[:courses_per_application] || DEFAULT_COURSES_COUNT).to_i, MAX_COURSES_COUNT].min
    end
  end
end

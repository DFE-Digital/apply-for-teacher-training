module VendorAPI
  class TestDataController < VendorAPIController
    VERSION = '1.0'.freeze

    before_action :check_this_is_a_test_environment

    MAX_COUNT = 100
    DEFAULT_COUNT = 100

    MAX_COURSES_COUNT = 3
    DEFAULT_COURSES_COUNT = 1

    def regenerate
      render json: { errors: [{ error: 'Functionality for this endpoint has been removed. Please use /test-data/clear and /test-data/generate.' }] }
    end

    def generate
      GenerateTestApplicationsForProvider.new(
        provider: current_provider,
        courses_per_application: courses_per_application_param,
        count: count_param,
        for_training_courses: for_training_courses_param,
        for_ratified_courses: for_ratified_courses_param,
        for_test_provider_courses: for_test_provider_courses_param,
      ).call

      render json: { data: { message: 'Request submitted. Applications will appear once they have been generated' } }
    rescue ParameterInvalid => e
      render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
    end

    def clear!
      ClearApplicationDataForProvider.call(current_provider)

      render json: { data: { message: 'Applications cleared' } }
    end

    def experimental_endpoint_moved
      new_endpoint_path = request.path.gsub('/experimental', '')

      render json: { data: { message: "Experimental endpoint #{request.path} has moved to #{new_endpoint_path}" } }, status: :gone
    end

  private

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

    def for_training_courses_param
      params[:for_training_courses] == 'true'
    end

    def for_ratified_courses_param
      params[:for_ratified_courses] == 'true'
    end

    def for_test_provider_courses_param
      params[:for_test_provider_courses] == 'true'
    end
  end
end

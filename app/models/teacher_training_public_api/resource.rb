module TeacherTrainingPublicAPI
  class Resource < JsonApiClient::Resource
    self.site = ENV.fetch('TEACHER_TRAINING_API_BASE_URL')
    self.connection_options = { headers: { user_agent: "Apply for teacher training #{HostingEnvironment.environment_name}" } }
  end
end

TeacherTrainingPublicAPI::Resource.connection do |connection|
  connection.use Faraday::Response::Logger, Rails.logger, formatter: APIRequestLoggingFormatter
end

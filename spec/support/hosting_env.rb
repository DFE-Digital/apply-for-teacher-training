RSpec.configure do |config|
  config.around(:each, :hosting_env) do |example|
    if example.metadata[:hosting_env].present?
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: example.metadata[:hosting_env] do
        example.run
      end
    else
      example.run
    end
  end
end

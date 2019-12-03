require 'rails_helper'

RSpec.describe 'Configuration' do
  describe 'azure/template.json' do
    it 'is valid JSON' do
      JSON.parse(File.read('azure/template.json'))
    end

    it 'includes the app-service variables in clockwork and sidekiq processes' do
      app_settings = resource('app-service').dig('properties', 'parameters', 'appServiceAppSettings', 'value').map { |v| v['name'] }
      worker_settings = resource('container-instances-worker').dig('properties', 'parameters', 'environmentVariables', 'value').map { |v| v['name'] }
      clock_settings = resource('container-instances-clock').dig('properties', 'parameters', 'environmentVariables', 'value').map { |v| v['name'] }

      settings_that_are_okay_to_differ = %w[APPINSIGHTS_INSTRUMENTATIONKEY
                                            BASIC_AUTH_PASSWORD BASIC_AUTH_USERNAME RAILS_SERVE_STATIC_FILES
                                            WEBSITES_CONTAINER_START_TIME_LIMIT
                                            WEBSITE_SLOT_POLL_WORKER_FOR_CHANGE_NOTIFICATION
                                            WEBSITE_SWAP_WARMUP_PING_PATH WEBSITE_SWAP_WARMUP_PING_STATUSES]

      expect(worker_settings).to match_array(app_settings - settings_that_are_okay_to_differ)
      expect(clock_settings).to match_array(app_settings - settings_that_are_okay_to_differ)
    end

    def resource(process)
      thing = JSON.parse(File.read('azure/template.json'))
      thing['resources'].find { |resource| resource['name'] == process }
    end
  end

  describe 'azure-pipelines.yml' do
    it 'is valid YAML' do
      YAML.load_file('azure-pipelines.yml')
    end
  end

  describe 'azure-pipelines-deploy-template.yml' do
    it 'is valid YAML' do
      YAML.load_file('azure-pipelines-deploy-template.yml')
    end
  end
end

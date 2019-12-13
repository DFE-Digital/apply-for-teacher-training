require 'rails_helper'

RSpec.describe 'Configuration' do
  describe 'azure/template.json' do
    it 'is valid JSON' do
      JSON.parse(File.read('azure/template.json'))
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

require 'rails_helper'

RSpec.describe 'Configuration' do
  describe 'azure/template.json' do
    it 'is valid JSON' do
      JSON.parse(File.read('azure/template.json'))
    end
  end

  describe 'azure-pipelines-yaml-files' do
    it 'are valid YAML' do
      Dir.glob(['azure-*.yml', '*-template.yml']).each do |template|
        puts template
        YAML.load_file(template)
      end
    end
  end
end

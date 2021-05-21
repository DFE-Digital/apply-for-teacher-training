require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::Provider do
  include TeacherTrainingPublicAPIHelper

  describe '.fetch' do
    it 'returns a provider that exists' do
      stub_teacher_training_api_provider(provider_code: 'MMM')

      provider = TeacherTrainingPublicAPI::Provider.fetch('MMM')

      expect(provider).to be_present
    end

    it 'returns nil when the provider does not exist' do
      stub_teacher_training_api_provider_404(provider_code: 'OOO')

      provider = TeacherTrainingPublicAPI::Provider.fetch('OOO')

      expect(provider).to be_nil
    end
  end
end

require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncAllProvidersAndCourses, sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  before do
    allow(described_class).to receive(:sync_providers)
  end

  describe '.call' do
    context 'paginates the correct number of pages' do
      it 'calls sync providers 3 times' do
        stub_teacher_training_api_providers_with_multiple_pages
        described_class.call

        expect(described_class).to have_received(:sync_providers).exactly(3).times
      end
    end
  end
end

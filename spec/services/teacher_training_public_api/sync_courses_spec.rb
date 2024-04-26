require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncCourses, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  describe 'syncing courses' do
    let!(:provider) { create(:provider) }
    let(:perform_job) do
      described_class.new.perform(provider.id,
                                  RecruitmentCycle.current_year)
    end

    before do
      stub_teacher_training_api_courses(provider_code: provider.code, specified_attributes: [{ accredited_body_code: nil }])
      allow(TeacherTrainingPublicAPI::SyncSites).to receive(:perform_async).and_return(true)
    end

    it 'creates courses' do
      expect { perform_job }.to change(provider.courses, :count)
    end
  end
end

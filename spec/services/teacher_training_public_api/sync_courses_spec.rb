require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncCourses, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  describe 'syncing courses' do
    let!(:provider) { create(:provider) }
    let(:perform_job) do
      described_class.new.perform(provider.id,
                                  RecruitmentCycle.current_year)
    end
    let(:stubbed_attributes) { [{ accredited_body_code: nil, state: stubbed_api_course_state }] }

    before do
      stub_teacher_training_api_courses(provider_code: provider.code, specified_attributes: stubbed_attributes)
      allow(TeacherTrainingPublicAPI::SyncSites).to receive(:perform_async).and_return(true)
    end

    context 'when courses are published' do
      let(:stubbed_api_course_state) { 'published' }

      it 'creates the courses' do
        expect { perform_job }.to change(provider.courses, :count)
      end
    end

    context 'when the API courses are withdrawn' do
      let(:stubbed_api_course_state) { 'withdrawn' }

      it 'creates the courses' do
        expect { perform_job }.to change(provider.courses, :count)
      end

      context 'when the course is published' do
        let(:uuid) { SecureRandom.uuid }
        let!(:course) { create(:course, provider: provider, withdrawn: false, uuid: uuid) }
        let(:stubbed_attributes) {
          [
            { accredited_body_code: nil, state: stubbed_api_course_state, uuid: uuid },
          ]
        }

        it 'updates the course to withdrawn' do
          expect { perform_job }.not_to change(Course, :count)
          expect(course.reload.withdrawn).to be_truthy
        end
      end
    end

    context 'when the API courses are rolled_over' do
      let(:stubbed_api_course_state) { 'rolled_over' }

      it 'does not create the courses' do
        expect { perform_job }.not_to change(Course, :count)
      end
    end

    context 'when the API courses are draft' do
      let(:stubbed_api_course_state) { 'draft' }

      it 'does not create the courses' do
        expect { perform_job }.not_to change(Course, :count)
      end
    end
  end
end

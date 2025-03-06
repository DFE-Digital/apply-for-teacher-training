require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncCourses, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  describe 'syncing courses' do
    let!(:provider) { create(:provider) }
    let(:perform_job) do
      described_class.new.perform(provider.id,
                                  RecruitmentCycle.current_year)
    end
    let(:stubbed_attributes) { [{ accredited_body_code: nil, state: stubbed_api_course_state, visa_sponsorship_application_deadline_at: stubbed_sponsorship_application_deadline_at }] }
    let(:stubbed_sponsorship_application_deadline_at) { nil }

    before do
      stub_teacher_training_api_courses(provider_code: provider.code, specified_attributes: stubbed_attributes)
      allow(TeacherTrainingPublicAPI::SyncSites).to receive(:perform_async).and_return(true)
    end

    context 'when the API course has a published state' do
      let(:stubbed_api_course_state) { 'published' }
      let(:stubbed_sponsorship_application_deadline_at) { nil }

      it 'creates the course' do
        expect { perform_job }.to change(provider.courses, :count)
      end
    end

    context 'when the sponsorship deadline is not provided' do
      let(:stubbed_api_course_state) { 'published' }

      it 'does not add visa_sponsorship_application_deadline_at value to course' do
        perform_job
        expect(provider.courses.where.not(visa_sponsorship_application_deadline_at: nil).count).to eq 0
      end
    end

    context 'when the sponsorship deadline is provided' do
      let(:stubbed_api_course_state) { 'published' }
      let(:stubbed_sponsorship_application_deadline_at) { 2.days.from_now }

      it 'saves the visa_sponsorship_application_deadline_at value to course' do
        perform_job
        expect(provider.courses.where.not(visa_sponsorship_application_deadline_at: nil).first.visa_sponsorship_application_deadline_at)
          .to be_within(1.second)
                .of(stubbed_sponsorship_application_deadline_at)
      end
    end

    context 'when the API course has a withdrawn state' do
      let(:stubbed_api_course_state) { 'withdrawn' }

      it 'creates the course' do
        expect { perform_job }.to change(provider.courses, :count)
      end

      context 'when the Course exists and has not been withdrawn' do
        let(:uuid) { SecureRandom.uuid }
        let!(:course) { create(:course, provider: provider, withdrawn: false, uuid: uuid) }
        let(:stubbed_attributes) {
          [
            { accredited_body_code: nil, state: stubbed_api_course_state, uuid: uuid },
          ]
        }

        it 'updates the Course to withdrawn' do
          expect { perform_job }.not_to change(Course, :count)
          expect(course.reload.withdrawn).to be_truthy
        end
      end
    end

    context 'when the API course has a rolled_over state' do
      let(:stubbed_api_course_state) { 'rolled_over' }

      it 'does not create the course' do
        expect { perform_job }.not_to change(Course, :count)
      end
    end

    context 'when the API course has a draft state' do
      let(:stubbed_api_course_state) { 'draft' }

      it 'does not create the course' do
        expect { perform_job }.not_to change(Course, :count)
      end
    end
  end
end

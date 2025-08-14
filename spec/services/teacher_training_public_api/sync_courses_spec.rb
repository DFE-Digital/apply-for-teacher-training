require 'rails_helper'

RSpec.describe TeacherTrainingPublicAPI::SyncCourses, :sidekiq do
  include TeacherTrainingPublicAPIHelper

  describe 'syncing courses' do
    let!(:provider) { create(:provider) }
    let(:perform_job) do
      described_class.new.perform(provider.id,
                                  current_year)
    end
    let(:stubbed_attributes) { [{ accredited_body_code: nil, state: stubbed_api_course_state, visa_sponsorship_application_deadline_at: stubbed_sponsorship_application_deadline_at, applications_open_from: stubbed_applications_open_from }] }
    let(:stubbed_sponsorship_application_deadline_at) { nil }
    let(:stubbed_applications_open_from) { nil }

    before do
      stub_teacher_training_api_courses(provider_code: provider.code, specified_attributes: stubbed_attributes)
      allow(TeacherTrainingPublicAPI::SyncSites).to receive(:perform_async).and_return(true)
    end

    context 'when the API course does not have a application_open_from date' do
      let(:stubbed_api_course_state) { 'published' }

      it 'uses the find opens date' do
        perform_job
        expect(provider.courses.last.applications_open_from).to eq current_timetable.find_opens_at
      end
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

    context 'when the open course exists and has been closed' do
      let(:uuid) { SecureRandom.uuid }
      let!(:course) { create(:course, :open, provider: provider, uuid: uuid) }
      let!(:invite) { create(:pool_invite, :sent_to_candidate, course:, provider:) }
      let(:stubbed_attributes) {
        [
          {
            accredited_body_code: nil,
            uuid: uuid,
            application_status: 'closed',
          },
        ]
      }

      it 'updates the course to closed including the invite' do
        expect { perform_job }.not_to change(Course, :count)
        expect(course.reload.open?).to be(false)
        expect(invite.reload.course_open).to be(false)
      end
    end

    context 'when the closed course exists and has been open' do
      let(:uuid) { SecureRandom.uuid }
      let!(:course) { create(:course, :closed, provider: provider, uuid: uuid) }
      let!(:invite) { create(:pool_invite, :sent_to_candidate, course:, provider:, course_open: false) }
      let(:stubbed_attributes) {
        [
          {
            accredited_body_code: nil,
            uuid: uuid,
            application_status: 'open',
          },
        ]
      }

      it 'updates the course to open including the invite' do
        expect { perform_job }.not_to change(Course, :count)
        expect(course.reload.open?).to be(true)
        expect(invite.reload.course_open).to be(true)
      end
    end

    context 'when the open course exists but apply is closed', time: after_apply_deadline do
      let(:uuid) { SecureRandom.uuid }
      let!(:course) { create(:course, :open, provider: provider, uuid: uuid) }
      let!(:invite) { create(:pool_invite, :sent_to_candidate, course:, provider:) }
      let(:stubbed_attributes) {
        [
          {
            accredited_body_code: nil,
            uuid: uuid,
            application_status: 'open',
          },
        ]
      }

      it 'updates the course to closed including the invite' do
        expect { perform_job }.not_to change(Course, :count)
        expect(course.reload.open?).to be(true)
        expect(invite.reload.course_open).to be(false)
      end
    end
  end
end

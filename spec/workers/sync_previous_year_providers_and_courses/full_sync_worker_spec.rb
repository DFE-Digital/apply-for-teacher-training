require 'rails_helper'

RSpec.describe SyncPreviousYearProvidersAndCourses::FullSyncWorker do
  it 'enqueues syncing job with expected arguments' do
    expect { described_class.perform_now }
      .to have_enqueued_job(TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker)
            .with(false, RecruitmentCycleTimetable.previous_year)
  end
end

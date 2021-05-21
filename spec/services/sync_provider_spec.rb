require 'rails_helper'

RSpec.describe SyncProvider do
  include TeacherTrainingPublicAPIHelper
  let(:provider) { create(:provider, code: 'ABC', sync_courses: false) }

  it 'enables course syncing' do
    SyncProvider.new(provider: provider).call

    expect(provider.sync_courses).to be true
  end

  it 'syncs the provider', sidekiq: true do
    stub_teacher_training_api_provider(provider_code: 'ABC', specified_attributes: { code: 'ABC' })
    stub_teacher_training_api_course_with_site(provider_code: 'ABC', course_code: '123', site_code: 'A', course_attributes: [{ accredited_body_code: nil }])

    expect(provider.courses.count).to be 0

    SyncProvider.new(provider: provider).call

    expect(provider.courses.count).to be 1
  end
end

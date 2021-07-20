require 'rails_helper'

RSpec.describe SyncProvider, sidekiq: true do
  include TeacherTrainingPublicAPIHelper
  let(:provider) { create(:provider, code: 'ABC', sync_courses: false) }

  before do
    stub_teacher_training_api_provider(provider_code: 'ABC', specified_attributes: { code: 'ABC' })
    stub_teacher_training_api_course_with_site(provider_code: 'ABC', course_code: '123', site_code: 'A', course_attributes: [{ accredited_body_code: nil }])
  end

  it 'enables course syncing during sync' do
    SyncProvider.new(provider: provider).call

    expect(provider.reload.sync_courses).to be true
  end

  it 'syncs the provider' do
    expect(provider.courses.count).to be 0

    SyncProvider.new(provider: provider).call

    expect(provider.courses.count).to be 1
  end
end

require 'rails_helper'

RSpec.describe FindSync::SyncProviderFromFind, sidekiq: true do
  include FindAPIHelper

  describe '.call' do
    context 'ingesting a brand new provider' do
      it 'does not create a new provider, or related courses, course options or sites' do
        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)

        provider = Provider.find_by_code('ABC')
        expect(provider).to be_nil

        expect(Course.count).to eq 0
        expect(CourseOption.count).to eq 0
        expect(Site.count).to eq 0
      end
    end

    context 'ingesting an existing provider not configured to sync courses' do
      before do
        @existing_provider = create :provider, code: 'ABC', sync_courses: false, name: 'ABC College'
        create :course, code: 'ABC1', provider: @existing_provider, subject_codes: %w[01 02 03]
      end

      it 'does not update the provider details' do
        stub_find_api_provider_200(
          provider_name: 'Foobar College',
          provider_code: 'ABC',
          course_code: 'ABC1',
          findable: true,
        )

        described_class.call(provider_name: 'Foobar College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        expect(Provider.find_by(code: 'ABC').name).to eq('ABC College')
      end

      it 'does not update the course subject codes' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: 'ABC1',
          findable: true,
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        course = Course.last
        expect(course.subject_codes).to eq(%w[01 02 03])
      end
    end

    context 'ingesting an existing provider configured to sync courses' do
      before do
        @existing_provider = create :provider, code: 'ABC', sync_courses: true, name: 'ABC College'
        create :course, code: 'ABC1', provider: @existing_provider, subject_codes: %w[01 02 03], description: 'PGCE with QTS full time', exposed_in_find: false
      end

      it 'does not update the provider details' do
        stub_find_api_provider_200(
          provider_name: 'Foobar College',
          provider_code: 'ABC',
          course_code: 'ABC1',
        )

        described_class.call(provider_name: 'Foobar College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        expect(Provider.find_by(code: 'ABC').name).to eq('ABC College')
      end

      it 'correctly updates the course subject codes' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: 'ABC1',
          findable: true,
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        course = Course.last
        expect(course.subject_codes).to eq(%w[08])
      end

      it 'does not update other data' do
        stub_find_api_provider_200(
          provider_code: 'ABC',
          course_code: 'ABC1',
          findable: true,
          description: 'PGCE with QTS full time with salary',
        )

        described_class.call(provider_name: 'ABC College', provider_code: 'ABC', provider_recruitment_cycle_year: stubbed_recruitment_cycle_year)
        course = Course.last
        expect(course.description).to eq('PGCE with QTS full time')
        expect(course.exposed_in_find).to be_falsey
      end
    end
  end
end

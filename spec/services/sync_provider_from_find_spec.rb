require 'rails_helper'

RSpec.describe SyncProviderFromFind do
  include FindAPIHelper

  describe 'ingesting provider, courses, sites and course_options for a provider_code' do
    it 'correctly creates all the entities' do
      stub_find_api_provider_200(
        provider_code: 'ABC',
        course_code: '9CBA',
        site_code: 'G',
        findable: true,
      )

      SyncProviderFromFind.call(provider_code: 'ABC')

      course_option = CourseOption.last

      expect(course_option.course.provider.code).to eq 'ABC'
      expect(course_option.course.code).to eq '9CBA'
      expect(course_option.course.exposed_in_find).to be true
      expect(course_option.site.code).to eq 'G'
    end

    it 'correctly handles accrediting providers' do
      stub_find_api_provider_200_with_accrediting_provider(
        provider_code: 'ABC',
        course_code: '9CBA',
        site_code: 'G',
        accrediting_provider_code: 'DEF',
        accrediting_provider_name: 'Test Accrediting Provider',
      )

      SyncProviderFromFind.call(provider_code: 'ABC')

      course_option = CourseOption.last

      expect(course_option.course.accrediting_provider.code).to eq 'DEF'
      expect(course_option.course.accrediting_provider.name).to eq 'Test Accrediting Provider'
    end
  end
end

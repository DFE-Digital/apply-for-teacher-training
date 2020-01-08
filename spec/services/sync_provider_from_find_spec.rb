require 'rails_helper'

RSpec.describe SyncProviderFromFind do
  include FindAPIHelper

  describe 'ingesting a new brand provider' do
    it 'correctly creates all the entities' do
      stub_find_api_provider_200(
        provider_code: 'ABC',
        course_code: '9CBA',
        site_code: 'G',
        findable: true,
      )

      SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

      provider = Provider.find_by_code('ABC')
      expect(provider).to be_present
      expect(provider.courses).to be_blank
    end
  end

  describe 'ingesting an existing provider not configured to sync courses' do
    before do
      @existing_provider = create :provider, code: 'ABC', name: 'DER College', sync_courses: false
    end

    it 'correctly creates all the entities' do
      stub_find_api_provider_200(
        provider_code: 'ABC',
        course_code: '9CBA',
        site_code: 'G',
        findable: true,
      )

      SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

      expect(@existing_provider.reload.courses).to be_blank
    end
  end

  describe 'ingesting an existing provider configured to sync courses, sites and course_options' do
    before do
      @existing_provider = create :provider, code: 'ABC', name: 'DER College', sync_courses: true
    end

    it 'correctly creates all the entities' do
      stub_find_api_provider_200(
        provider_code: 'ABC',
        course_code: '9CBA',
        site_code: 'G',
        findable: true,
      )

      SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

      course_option = CourseOption.last

      expect(course_option.course.provider.code).to eq 'ABC'
      expect(course_option.course.code).to eq '9CBA'
      expect(course_option.course.exposed_in_find).to be true
      expect(course_option.course.recruitment_cycle_year).to be FindAPI::RECRUITMENT_CYCLE_YEAR
      expect(course_option.site.name).to eq 'Main site'
      expect(course_option.site.address_line1).to eq 'Gorse SCITT'
      expect(course_option.site.address_line2).to eq 'C/O The Bruntcliffe Academy'
      expect(course_option.site.address_line3).to eq 'Bruntcliffe Lane'
      expect(course_option.site.address_line4).to eq 'MORLEY, LEEDS'
      expect(course_option.site.postcode).to eq 'LS27 0LZ'
    end

    it 'correctly handles accrediting providers' do
      stub_find_api_provider_200_with_accrediting_provider(
        provider_code: 'ABC',
        course_code: '9CBA',
        site_code: 'G',
        study_mode: 'full_time',
        accrediting_provider_code: 'DEF',
        accrediting_provider_name: 'Test Accrediting Provider',
      )

      SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

      course_option = CourseOption.last

      expect(course_option.course.accrediting_provider.code).to eq 'DEF'
      expect(course_option.course.accrediting_provider.name).to eq 'Test Accrediting Provider'
    end

    it 'stores full_time/part_time information within courses' do
      stub_find_api_provider_200_with_accrediting_provider(
        provider_code: 'ABC',
        course_code: '9CBA',
        study_mode: 'full_time_or_part_time',
      )

      SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

      course = Provider.find_by_code('ABC').courses.find_by_code('9CBA')
      expect(course.study_mode).to eq 'full_time_or_part_time'
    end

    it 'creates the correct number of course_options for sites and study_mode' do
      stub_find_api_provider_200_with_multiple_sites(
        provider_code: 'ABC',
        course_code: '9CBA',
        study_mode: 'full_time_or_part_time',
      )

      SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC')

      provider = Provider.find_by_code('ABC')
      course_options = provider.courses.find_by_code('9CBA').course_options

      expect(course_options.count).to eq 4
      provider.sites.each do |site|
        modes_for_site = course_options.where(site_id: site.id).pluck(:study_mode)
        expect(modes_for_site).to match_array %w[full_time part_time]
      end
    end
  end
end

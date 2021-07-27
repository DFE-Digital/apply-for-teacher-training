require 'rails_helper'

RSpec.describe GetAllChangeOptionsFromOfferedOption do
  include CourseOptionHelpers

  let(:provider_user) { create(:provider_user, :with_two_providers) }
  let(:available_providers) { provider_user.providers }
  let(:course_option) { course_option_for_provider_code(provider_code: available_providers.first.code) }
  let(:application_choice) { create(:application_choice, :with_offer, course_option: course_option) }

  let(:service) do
    described_class.new(
      application_choice: application_choice,
      available_providers: available_providers,
    )
  end

  describe '#call' do
    let(:returned_hash) { service.call }

    it 'returns a hash of available providers, courses, study_modes and course_options' do
      expect(returned_hash.keys).to \
        eq %i[available_providers available_courses available_study_modes available_course_options]
    end

    it 'includes all providers associated with the user' do
      create(:provider)
      expect(returned_hash[:available_providers]).to eq(provider_user.providers)
    end

    it 'includes all courses offered by current option\'s provider (subject to status, study_mode and year)' do
      provider = course_option.course.provider
      true_alternative = create(:course, :open_on_apply, :full_time, provider: provider)
      not_open = create(:course, provider: provider, open_on_apply: false)
      wrong_year = create(:course, :open_on_apply, provider: provider, recruitment_cycle_year: 2019)
      part_time_only = create(:course, :open_on_apply, :part_time, provider: provider)
      both_study_modes = create(:course, :open_on_apply, :with_both_study_modes, provider: provider)

      expect(returned_hash[:available_courses]).to include(course_option.course)
      expect(returned_hash[:available_courses]).to include(true_alternative)
      expect(returned_hash[:available_courses]).to include(both_study_modes)
      expect(returned_hash[:available_courses]).not_to include(not_open)
      expect(returned_hash[:available_courses]).not_to include(wrong_year)
      expect(returned_hash[:available_courses]).not_to include(part_time_only)
    end

    it 'includes all study modes available for the course' do
      course = course_option.course
      create(:course_option, :part_time, course: course)

      expect(returned_hash[:available_study_modes]).to match_array(%w[full_time part_time])
    end

    it 'includes all course options for current course (subject to study_mode)' do
      course = course_option.course
      true_alternative = create(:course_option, course: course)
      part_time = create(:course_option, :part_time, course: course)

      expect(returned_hash[:available_course_options]).to include(course_option)
      expect(returned_hash[:available_course_options]).to include(true_alternative)
      expect(returned_hash[:available_course_options]).not_to include(part_time)
    end
  end
end

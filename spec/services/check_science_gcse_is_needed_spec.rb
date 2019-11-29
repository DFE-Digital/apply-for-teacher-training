require 'rails_helper'

RSpec.describe CheckScienceGcseIsNeeded do
  describe '.call' do
    context 'when a candidate has no course choices' do
      it 'returns false' do
        application_form = build_stubbed(:application_form)

        science_gcse_is_needed = CheckScienceGcseIsNeeded.call(application_form)

        expect(science_gcse_is_needed).to eq(false)
      end
    end

    context 'when a candidate has a course choice that is primary' do
      it 'returns true' do
        application_form = application_form_with_course_option_for_provider_with(level: 'primary')

        science_gcse_is_needed = CheckScienceGcseIsNeeded.call(application_form)

        expect(science_gcse_is_needed).to eq(true)
      end
    end

    context 'when a candidate has a course choice that is secondary' do
      it 'returns false' do
        application_form = application_form_with_course_option_for_provider_with(level: 'secondary')

        science_gcse_is_needed = CheckScienceGcseIsNeeded.call(application_form)

        expect(science_gcse_is_needed).to eq(false)
      end
    end

    context 'when a candidate has a course choice that is further education' do
      it 'returns false' do
        application_form = application_form_with_course_option_for_provider_with(level: 'further_education')

        science_gcse_is_needed = CheckScienceGcseIsNeeded.call(application_form)

        expect(science_gcse_is_needed).to eq(false)
      end
    end

    def application_form_with_course_option_for_provider_with(level:)
      provider = build(:provider)
      course = create(:course, level: level, provider: provider)
      site = create(:site, provider: provider)
      course_option = create(:course_option, course: course, site: site)
      application_form = create(:application_form)

      create(
        :application_choice,
        application_form: application_form,
        course_option: course_option,
      )

      application_form
    end
  end
end

require 'rails_helper'

RSpec.describe GetCourseOptionFromCodes, type: :model do
  include CourseOptionHelpers

  let(:course_option) { create(:course_option) }

  let(:service) do
    described_class.new(
      provider_code: course_option.course.provider.code,
      course_code: course_option.course.code,
      study_mode: course_option.course.study_mode,
      site_code: course_option.site.code,
      recruitment_cycle_year: course_option.course.recruitment_cycle_year,
    )
  end

  describe 'validation' do
    subject { service }

    required_attributes = %i[provider_code course_code study_mode recruitment_cycle_year]
    required_attributes.each do |attr|
      it { is_expected.to validate_presence_of(attr).with_message("#{attr.to_s.humanize} cannot be blank") }

      it "does not add errors to other attributes when #{attr} is blank" do
        service.send("#{attr}=", nil)
        expect(service).not_to be_valid
        expect(service.errors.attribute_names).to contain_exactly(attr)
      end
    end

    context 'when the site code is given but does not match any course option' do
      let(:another_course) { create(:course, provider: course_option.provider) }
      let(:site_for_another_course) { create(:site, code: 'QQ', provider: course_option.provider) }
      let!(:course_option_for_another_course) { create(:course_option, course: another_course, site: site_for_another_course) }

      it 'is not valid, feature flag inactive' do
        FeatureFlag.deactivate(:handle_duplicate_sites_test)
        service.site_code = site_for_another_course.code
        expect(service).not_to be_valid
        expected_message = "Cannot find any #{course_option.course.study_mode} options at site #{site_for_another_course.code} for course #{course_option.course.code}"
        expect(service.errors[:course_option]).to contain_exactly(expected_message)
      end

      it 'is not valid, feature flag active' do
        FeatureFlag.activate(:handle_duplicate_sites_test)
        service.site_code = site_for_another_course.code
        expect(service).not_to be_valid
        expected_message = "Site #{site_for_another_course.code} does not exist for provider #{course_option.provider.code} in #{course_option.course.recruitment_cycle_year}"
        expect(service.errors[:site_code]).to contain_exactly(expected_message)
      end
    end

    context 'when the site code is blank but unambiguous' do
      it 'is valid' do
        service.site_code = nil
        expect(service).to be_valid
      end
    end

    context 'when there are duplicate sites' do
      let(:duplicate_site) do
        create(:site, code: course_option.site.code, provider: course_option.provider)
      end
      let!(:another_course_option) do
        create(
          :course_option,
          course: course_option.course,
          site: duplicate_site,
          study_mode: course_option.study_mode,
          site_still_valid: site_still_valid,
        )
      end

      context 'matching course option is selectable' do
        let(:site_still_valid) { true }

        it 'is not valid' do
          expect(service).not_to be_valid
          expected_message = "Found multiple #{course_option.course.study_mode} options for course #{course_option.course.code}"
          expect(service.errors[:course_option]).to contain_exactly(expected_message)
        end
      end

      context 'matching course option is not selectable' do
        let(:site_still_valid) { false }

        it 'is valid' do
          expect(service).to be_valid
        end
      end
    end

    context 'when the site code is blank and ambiguous' do
      let!(:another_course_option) { create(:course_option, course: course_option.course) }

      it 'is not valid' do
        service.site_code = nil
        expect(service).not_to be_valid
        expected_message = "Found multiple #{course_option.course.study_mode} options for course #{course_option.course.code}"
        expect(service.errors[:course_option]).to contain_exactly(expected_message)
      end
    end

    context 'when the site code exists in a different cycle year' do
      let(:course) { create(:course) }
      let(:course_previous_year) { create(:course, :previous_year, provider: course.provider) }
      let(:site_from_previous_year) { create(:site, code: '-', provider: course.provider) }
      let(:site_from_current_year) { create(:site, code: '-', provider: course.provider) }
      let!(:course_option) { create(:course_option, site: site_from_current_year, course:) }
      let!(:course_option_from_previous_year) { create(:course_option, :previous_year, site: site_from_previous_year, course: course_previous_year) }

      it 'is valid' do
        expect(service).to be_valid
      end
    end

    context 'when the site code is a duplicate in the same cycle year and same course' do
      let(:another_course) { create(:course, provider: course_option.provider) }
      let(:duplicate_site_code) { create(:site, code: course_option.site.code, provider: course_option.provider) }
      let!(:course_option_for_another_course) { create(:course_option, course: course_option.course, site: duplicate_site_code) }

      it 'is invalid' do
        expect(service).not_to be_valid

        expected_message = "Found multiple sites with code: #{course_option.site.code} for provider: " \
                           "#{course_option.provider.code} in the current cycle"
        expect(service.errors[:site_code]).to contain_exactly(expected_message)
      end
    end
  end

  describe '#call' do
    it 'returns the course_option if it can find it' do
      expect(service.call).to eq(course_option)
    end

    it 'returns nil if it cannot find the course option' do
      service.recruitment_cycle_year = 2017
      expect(service.call).to be_nil
    end
  end
end

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
        expect(service).to be_invalid
        expect(service.errors.attribute_names).to contain_exactly(attr)
      end
    end

    context 'when the site code is given but does not match any course option' do
      let!(:site_for_another_course) { create(:site, code: 'QQ', provider: course_option.provider) }

      it 'is not valid' do
        service.site_code = site_for_another_course.code
        expect(service).to be_invalid
        expected_message = "Cannot find any #{course_option.course.study_mode} options at site #{site_for_another_course.code} for course #{course_option.course.code}"
        expect(service.errors[:course_option]).to contain_exactly(expected_message)
      end
    end

    context 'when the site code is blank but unambiguous' do
      it 'is valid' do
        service.site_code = nil
        expect(service).to be_valid
      end
    end

    context 'when the site code is blank and ambiguous' do
      let!(:another_course_option) { create(:course_option, course: course_option.course) }

      it 'is not valid' do
        service.site_code = nil
        expect(service).to be_invalid
        expected_message = "Found multiple #{course_option.course.study_mode} options for course #{course_option.course.code}"
        expect(service.errors[:course_option]).to contain_exactly(expected_message)
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

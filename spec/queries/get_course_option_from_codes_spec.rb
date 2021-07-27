require 'rails_helper'

RSpec.describe GetCourseOptionFromCodes do
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
    required_attributes = %w[provider_code course_code study_mode site_code recruitment_cycle_year]
    required_attributes.each do |attr|
      it "complains about missing #{attr}" do
        service.send("#{attr}=".to_sym, 'random')
        expect(service).not_to be_valid
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

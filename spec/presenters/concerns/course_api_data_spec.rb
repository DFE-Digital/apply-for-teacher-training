require 'rails_helper'

RSpec.describe CourseAPIData do
  subject(:presenter) { CourseAPIDataClass.new(application_choice) }

  let!(:application_choice) { create(:application_choice, :awaiting_provider_decision, :with_completed_application_form) }
  let(:course_data_class) do
    Class.new do
      include CourseAPIData

      attr_accessor :application_choice, :application_form

      def initialize(application_choice)
        @application_choice = ApplicationChoiceExportDecorator.new(application_choice)
        @application_form = application_choice.application_form
      end
    end
  end

  before do
    stub_const('CourseAPIDataClass', course_data_class)
  end

  describe '#course_info_for' do
    let(:course_option) { create(:course_option) }

    it 'maps course information' do
      expect(presenter.course_info_for(course_option)).to eq({
        recruitment_cycle_year: course_option.course.recruitment_cycle_year,
        provider_code: course_option.course.provider.code,
        site_code: course_option.site.code,
        course_code: course_option.course.code,
        study_mode: course_option.study_mode,
        start_date: course_option.course.start_date.strftime('%Y-%m'),
      })
    end
  end

  describe '#current_course' do
    let(:course_option) { application_choice.current_course_option }

    it 'maps course information' do
      expect(presenter.current_course).to eq({
        course: {
          recruitment_cycle_year: course_option.course.recruitment_cycle_year,
          provider_code: course_option.course.provider.code,
          site_code: course_option.site.code,
          course_code: course_option.course.code,
          study_mode: course_option.study_mode,
          start_date: course_option.course.start_date.strftime('%Y-%m'),
        },
      })
    end
  end
end

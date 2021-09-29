require 'rails_helper'

RSpec.describe GetApplicationProgressDataByCourse do
  describe '#call' do
    let(:report_provider) { create(:provider) }
    let(:accredited_provider) { create(:provider) }
    let(:course) { create(:course, name: 'Alpha Physics', code: '2AIC', provider: report_provider, accredited_provider: nil) }
    let(:course_option) { create(:course_option, course: course) }
    let(:accredited_course) { create(:course, name: 'Beta Physics', accredited_provider: report_provider, provider: accredited_provider) }
    let(:accredited_course_option) { create(:course_option, course: accredited_course) }
    let(:third_course) { create(:course, name: 'Alpha Physics', code: '1ABX', provider: report_provider, accredited_provider: nil) }
    let(:third_option) { create(:course_option, course: third_course) }
    let!(:empty_course) { create(:course, name: 'Cappa', provider: report_provider) }
    let!(:empty_course_option) { create(:course_option, course: empty_course) }

    before do
      create_list(:application_choice, 10, status: :interviewing, course_option: accredited_course_option)
      create_list(:application_choice, 5, status: :pending_conditions, course_option: accredited_course_option)
      create_list(:application_choice, 8, status: :interviewing, course_option: course_option)
      create_list(:application_choice, 3, status: :pending_conditions, course_option: course_option)
      create_list(:application_choice, 6, status: :awaiting_provider_decision, course_option: third_option)
    end

    subject(:progress_data) { described_class.new(provider: report_provider).call }

    it 'generates the correct count' do
      expect(progress_data.map(&:count).inject(:+)).to eq(33)
    end

    it 'retrieves courses with no applications' do
      expect(progress_data.length).to eq(6)
    end

    it 'retrieves the courses in alphabetical order' do
      expect(progress_data.first).to eq(third_course)
      expect(progress_data.second).to eq(course)
      expect(progress_data.fourth).to eq(accredited_course)
      expect(progress_data.last).to eq(empty_course)
    end

    it 'can group the courses by id' do
      courses = progress_data.group_by(&:id)
      provider_courses = courses[course.id]
      accredited_provider_courses = courses[accredited_course.id]

      expect(provider_courses.find { |c| c.status == 'interviewing' }.count).to eq(8)
      expect(provider_courses.find { |c| c.status == 'pending_conditions' }.count).to eq(3)

      expect(accredited_provider_courses.find { |c| c.status == 'interviewing' }.count).to eq(10)
      expect(accredited_provider_courses.find { |c| c.status == 'pending_conditions' }.count).to eq(5)
    end

    it 'only shows results for the current recuitment cycle year' do
      previous_year_course = create(:course, name: 'Alpha Plus Physics', code: '2AIC', provider: report_provider, accredited_provider: nil, recruitment_cycle_year: RecruitmentCycle.previous_year)
      previous_year_course_option = create(:course_option, course: previous_year_course)
      create_list(:application_choice, 5, status: :pending_conditions, course_option: previous_year_course_option)
      expect(progress_data).not_to include(previous_year_course)
      expect(progress_data.length).to eq(6)
    end

    it 'only shows results for the current recuitment cycle year for when we are the accredited provider' do
      previous_year_course = create(:course, name: 'Alpha Plus Physics', code: '2AIC', provider: accredited_provider, accredited_provider: report_provider, recruitment_cycle_year: RecruitmentCycle.previous_year)
      previous_year_course_option = create(:course_option, course: previous_year_course)
      create_list(:application_choice, 5, status: :pending_conditions, course_option: previous_year_course_option)
      expect(progress_data).not_to include(previous_year_course)
      expect(progress_data.length).to eq(6)
    end
  end
end

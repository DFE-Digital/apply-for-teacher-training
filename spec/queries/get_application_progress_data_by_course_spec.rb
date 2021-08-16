require 'rails_helper'

RSpec.describe GetApplicationProgressDataByCourse do
  describe '#call' do
    let(:provider) { create(:provider) }
    let(:accredited_provider) { create(:provider) }
    let(:course) { create(:course, provider: provider, accredited_provider: nil) }
    let(:course_option) { create(:course_option, course: course) }
    let(:accredited_course) { create(:course, accredited_provider: provider, provider: accredited_provider) }
    let(:accredited_course_option) { create(:course_option, course: accredited_course) }

    before do
      create_list(:application_choice, 10, status: :interviewing, course_option: accredited_course_option)
      create_list(:application_choice, 5, status: :pending_conditions, course_option: accredited_course_option)
      create_list(:application_choice, 8, status: :interviewing, course_option: course_option)
      create_list(:application_choice, 3, status: :pending_conditions, course_option: course_option)
    end

    it 'generates the correct count' do
      expect(described_class.new(provider: provider).call.map(&:count).inject(:+)).to eq(26)
    end

    it 'can group the courses by id' do
      courses = described_class.new(provider: provider).call.group_by(&:id)
      provider_courses = courses[course.id]
      accredited_provider_courses = courses[accredited_course.id]

      expect(provider_courses.find { |c| c.status == 'interviewing' }.count).to eq(8)
      expect(provider_courses.find { |c| c.status == 'pending_conditions' }.count).to eq(3)

      expect(accredited_provider_courses.find { |c| c.status == 'interviewing' }.count).to eq(10)
      expect(accredited_provider_courses.find { |c| c.status == 'pending_conditions' }.count).to eq(5)
    end
  end
end

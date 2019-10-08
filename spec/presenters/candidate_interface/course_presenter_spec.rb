require 'rails_helper'

RSpec.describe CandidateInterface::CoursePresenter do
  let(:provider_code) { '2AT' }
  let(:course_code) { '1234' }
  let(:name) { 'Biology' }
  let(:find_course) {
    FindAPI::Course.new(
      provider_code: provider_code, course_code: course_code, name: name,
    )
  }
  let(:course) { described_class.new find_course }

  describe '#name_and_code' do
    it 'returns name and code' do
      expect(course.name_and_code).to eq("#{name} (#{course_code})")
    end
  end
end

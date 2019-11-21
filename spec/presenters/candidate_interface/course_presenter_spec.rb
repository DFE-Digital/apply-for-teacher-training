require 'rails_helper'

RSpec.describe CandidateInterface::CoursePresenter do
  describe '#name_and_code' do
    it 'returns name and code' do
      course = Course.new(name: 'Yo', code: 'ABC')

      expect(course.name_and_code).to eq('Yo (ABC)')
    end
  end
end

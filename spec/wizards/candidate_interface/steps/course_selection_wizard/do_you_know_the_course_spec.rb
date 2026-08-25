require 'rails_helper'

RSpec.describe CandidateInterface::Steps::CourseSelectionWizard::DoYouKnowTheCourse, type: :model do
  describe 'attributes' do
    it 'has attributes associated with the form' do
      expect(described_class.new).to have_attributes(answer: nil)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:answer) }
  end

  describe '#permitted_params' do
    it 'returns the permitted_params' do
      expect(described_class.permitted_params).to contain_exactly(:answer)
    end
  end
end

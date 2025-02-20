require 'rails_helper'

RSpec.describe Adviser::TeacherTrainingAdviserSignUpDecorator do
  describe '#attributes_as_snake_case' do
    it 'returns a hash of attributes, transforming the keys from camelCase to snake_case' do
      api_model = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(first_name: 'John', last_name: 'Doe')
      attributes = described_class.new(api_model).attributes_as_snake_case
      expect(attributes).to eq({ first_name: 'John', last_name: 'Doe' })
    end
  end

  describe '#adviser_status' do
    it 'returns unassigned when assignment_status_id is not set' do
      expect(described_class.new({}).adviser_status).to eq('unassigned')
    end

    context 'when assignment_status_id is set' do
      it 'returns waiting_to_be_assigned when assignment_status_id is 222_750_001' do

        teacher_training_advisor = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(assignment_status_id: 222_750_001)
        decorator = described_class.new(teacher_training_advisor)
        expect(decorator.adviser_status).to eq('waiting_to_be_assigned')
      end
    end
  end
end

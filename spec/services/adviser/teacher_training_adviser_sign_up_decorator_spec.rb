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
      {
        unassigned: 222_750_000,
        waiting_to_be_assigned: 222_750_001,
        assigned: 222_750_002,
        previously_assigned: 222_750_003,
      }.each do |expected_advisor_status, assignment_status_id|
        it "returns #{expected_advisor_status} when assignment_status_id is #{assignment_status_id}" do
          teacher_training_advisor = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(assignment_status_id: assignment_status_id)
          decorator = described_class.new(teacher_training_advisor)
          expect(decorator.adviser_status).to eq(expected_advisor_status.to_s)
        end
      end

      it 'returns unassigned when assignment_status_id is not recognised' do
        teacher_training_advisor = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(assignment_status_id: 'some_unknown_status_id')
        decorator = described_class.new(teacher_training_advisor)
        expect(decorator.adviser_status).to eq('unassigned')
      end
    end
  end
end

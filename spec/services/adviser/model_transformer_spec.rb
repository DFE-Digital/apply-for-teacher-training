require 'rails_helper'

RSpec.describe Adviser::ModelTransformer do
  describe 'get_attributes_as_snake_case' do
    it 'returns a hash of attributes, transforming the keys from camelCase to snake_case' do
      model = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(first_name: 'John', last_name: 'Doe')
      attributes = described_class.get_attributes_as_snake_case(model)
      expect(attributes).to eq({ first_name: 'John', last_name: 'Doe' })
    end
  end
end

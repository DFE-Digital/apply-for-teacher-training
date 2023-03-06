require 'rails_helper'

RSpec.describe Adviser::APIModelDecorator do
  describe '#attributes_as_snake_case' do
    it 'returns a hash of attributes, transforming the keys from camelCase to snake_case' do
      api_model = GetIntoTeachingApiClient::TeacherTrainingAdviserSignUp.new(first_name: 'John', last_name: 'Doe')
      attributes = described_class.new(api_model).attributes_as_snake_case
      expect(attributes).to eq({ first_name: 'John', last_name: 'Doe' })
    end
  end
end

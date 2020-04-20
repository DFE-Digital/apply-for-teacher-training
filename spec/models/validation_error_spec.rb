require 'rails_helper'

RSpec.describe ValidationError, type: :model do
  subject { create(:validation_error) }

  describe 'a valid validation error' do
    it { is_expected.to validate_presence_of :form_object }
  end
end

require 'rails_helper'

RSpec.describe CreateNote do
  let(:application_choice) { build(:application_choice) }
  let(:user) { [0, 1].sample.zero? ? build(:vendor_api_user) : build(:provider_user) }

  describe '#save!' do
    it 'with valid data it creates a new note' do
      valid_form_object = described_class.new(
        application_choice: application_choice,
        user: user,
        message: 'Some text',
      )

      expect { valid_form_object.save! }.to change { application_choice.notes.count }.from(0).to(1)
    end

    it 'with invalid data it raises' do
      invalid_form_object = described_class.new(
        application_choice: application_choice,
        user: user,
        message: nil,
      )

      expect { invalid_form_object.save! }.to raise_error(ValidationException, 'Enter a note')
    end
  end
end

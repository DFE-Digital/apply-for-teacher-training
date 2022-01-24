require 'rails_helper'

RSpec.describe ProviderInterface::NewNoteForm do
  let(:application_choice) { build(:application_choice) }
  let(:user) { build(:provider_user) }

  describe '#save' do
    it 'creates a new note' do
      valid_form_object = described_class.new(
        application_choice: application_choice,
        user: user,
        message: 'Some text',
      )

      expect { valid_form_object.save }.to change { application_choice.notes.count }.from(0).to(1)
    end

    it 'fails for invalid forms' do
      invalid_form_object = described_class.new(application_choice: application_choice)
      expect { invalid_form_object.save }.not_to(change { application_choice.notes.count })
    end
  end
end

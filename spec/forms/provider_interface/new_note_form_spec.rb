require 'rails_helper'

RSpec.describe ProviderInterface::NewNoteForm do
  let(:application_choice) { build(:application_choice) }
  let(:provider_user) { build(:provider_user) }

  describe 'validations' do
    it 'validates presence of :application_choice' do
      expect(described_class.new).to validate_presence_of(:application_choice)
        .with_message('Missing application_choice')
    end

    it 'validates presence of and length of :message' do
      expect(described_class.new).to validate_presence_of(:message)
        .with_message('Enter a note')

      expect(described_class.new).to validate_length_of(:message)
        .is_at_most(500)
        .with_message('The note must be 500 characters or fewer')
    end

    it 'validates presence of :provider_user' do
      expect(described_class.new).to validate_presence_of(:provider_user)
        .with_message('Missing provider_user')
    end
  end

  describe '#save' do
    it 'creates a new note' do
      valid_form_object = described_class.new(
        application_choice: application_choice,
        provider_user: provider_user,
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

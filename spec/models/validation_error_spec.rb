require 'rails_helper'

RSpec.describe ValidationError, type: :model do
  subject { create(:validation_error) }

  describe 'a valid validation error' do
    it { is_expected.to validate_presence_of :form_object }
  end

  describe '.list_of_distinct_errors_with_count' do
    it 'returns a list of grouped errors' do
      create_list(:validation_error, 2)

      expect(described_class.list_of_distinct_errors_with_count).to contain_exactly(
        [
          [
            'RefereeInterface::ReferenceFeedbackForm',
            'feedback',
            'Enter feedback',
          ],
          2,
        ],
      )
    end

    it 'sorts the list of errors by occurrence' do
      create(:validation_error, form_object: 'PersonalDetailsForm', details: { date_of_birth: { messages: ['Enter a date of birth'], value: '' } })
      create_list(:validation_error, 2)

      expect(described_class.list_of_distinct_errors_with_count).to contain_exactly(
        [
          [
            'RefereeInterface::ReferenceFeedbackForm',
            'feedback',
            'Enter feedback',
          ],
          2,
        ],
        [
          [
            'PersonalDetailsForm',
            'date_of_birth',
            'Enter a date of birth',
          ],
          1,
        ],
      )
    end
  end

  describe '.search' do
    it 'returns all validation errors with empty params' do
      validation_error = create(:validation_error)

      expect(described_class.search({})).to contain_exactly(validation_error)
    end

    it 'returns validation errors scoped to form object' do
      validation_error = create(:validation_error)
      params = { form_object: validation_error.form_object }

      expect(described_class.search(params)).to contain_exactly(validation_error)
    end

    it 'returns validation errors scoped to user' do
      validation_error = create(:validation_error)
      params = { user_id: validation_error.user_id }

      expect(described_class.search(params)).to contain_exactly(validation_error)
    end

    it 'returns validation errors scoped to validation_error id' do
      validation_error = create(:validation_error)
      params = { id: validation_error.id }

      expect(described_class.search(params)).to contain_exactly(validation_error)
    end

    it 'returns validation errors scoped to error attribute' do
      validation_error = create(:validation_error)
      params = { attribute: 'feedback' }

      expect(described_class.search(params)).to contain_exactly(validation_error)
    end

    it 'returns validation errors scoped to multiple parameters' do
      validation_error = create(:validation_error)

      create(:validation_error, form_object: 'PersonalDetailsForm', user: validation_error.user)

      params = { user: validation_error.user, form_object: 'RefereeInterface::ReferenceFeedbackForm' }

      expect(described_class.search(params)).to contain_exactly(validation_error)
    end

    it 'returns empty result if no validation errors found' do
      expect(described_class.search({})).to be_empty
    end
  end
end

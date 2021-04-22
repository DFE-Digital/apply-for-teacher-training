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
end

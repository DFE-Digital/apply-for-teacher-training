require 'rails_helper'

RSpec.describe CandidateInterface::EqualityAndDiversityCompleteForm do
  context 'when did not answer all questions' do
    let(:current_application) { create(:application_form, equality_and_diversity: nil) }

    context 'when mark as incomplete' do
      it 'is valid' do
        form = described_class.new(current_application:, completed: 'false')
        expect(form).to be_valid
      end
    end

    context 'when mark as completed' do
      it 'is invalid' do
        form = described_class.new(current_application:, completed: 'true')
        expect(form).not_to be_valid
      end
    end
  end

  context 'when did not answer any questions' do
    let(:current_application) do
      create(:application_form, equality_and_diversity: { sex: 'male' })
    end

    context 'when mark as incomplete' do
      it 'is valid' do
        form = described_class.new(current_application:, completed: 'false')
        expect(form).to be_valid
      end
    end

    context 'when mark as completed' do
      it 'is invalid' do
        form = described_class.new(current_application:, completed: 'true')
        expect(form).not_to be_valid
      end
    end
  end

  context 'when all minimal answers are provided' do
    let(:current_application) do
      create(
        :application_form,
        equality_and_diversity: {
          sex: 'answer',
          ethnic_group: 'some answer',
          disabilities: ['some answer'],
        },
      )
    end

    context 'when mark as incomplete' do
      it 'is valid' do
        form = described_class.new(current_application:, completed: 'false')
        expect(form).to be_valid
      end
    end

    context 'when mark as completed' do
      it 'is valid' do
        form = described_class.new(current_application:, completed: 'true')
        expect(form).to be_valid
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::ImmigrationStatus do
  subject(:immigration_status_service) { described_class.new(current_application:) }

  let(:current_application) { create(:application_form, first_nationality:, second_nationality:, right_to_work_or_study:, immigration_status:) }

  let(:immigration_status) { nil }
  let(:right_to_work_or_study) { 'no' }
  let(:first_nationality) { 'Canadian' }
  let(:second_nationality) { nil }

  describe '#incomplete?' do
    context 'when the candidate has the right to work or study and is not British or Irish' do
      let(:right_to_work_or_study) { 'yes' }
      let(:first_nationality) { 'Canadian' }
      let(:second_nationality) { 'Australian' }

      it 'returns true if immigration status is blank' do
        expect(immigration_status_service.incomplete?).to be true
      end

      it 'returns false if immigration status is present' do
        current_application.update!(immigration_status: 'eu_settled')
        expect(immigration_status_service.incomplete?).to be false
      end
    end

    context 'when the candidate has the right to work or study' do
      let(:right_to_work_or_study) { 'yes' }

      context 'and they are British or Irish' do
        it 'returns false regardless of immigration status' do
          %w[British Irish].each do |nationality|
            current_application.update!(first_nationality: nationality)
            expect(immigration_status_service.incomplete?).to be false
          end
        end
      end
    end

    context 'when the candidate does not have the right to work or study' do
      let(:right_to_work_or_study) { 'no' }
      let(:first_nationality) { 'Canadian' }
      let(:second_nationality) { nil }

      it 'returns false regardless of immigration status' do
        expect(immigration_status_service.incomplete?).to be false
      end
    end
  end

  describe '#british_or_irish?' do
    let(:right_to_work_or_study) { 'no' }

    context 'when the candidate is British or Irish' do
      it 'returns true if nationality is British or Irish' do
        %w[British Irish].each do |nationality|
          current_application.update!(first_nationality: nationality)
          expect(immigration_status_service.british_or_irish?).to be true
        end
      end
    end

    context 'when the candidate is not British or Irish' do
      it 'returns false' do
        current_application.update!(first_nationality: 'Canadian')
        expect(immigration_status_service.british_or_irish?).to be false
      end
    end
  end

  describe '#right_to_work_or_study?' do
    context 'when the candidate has the right to work or study' do
      let(:right_to_work_or_study) { 'yes' }

      it 'returns true' do
        expect(immigration_status_service.right_to_work_or_study?).to be true
      end
    end

    context 'when the candidate does not have the right to work or study' do
      let(:right_to_work_or_study) { 'no' }

      it 'returns false' do
        expect(immigration_status_service.right_to_work_or_study?).to be false
      end
    end
  end
end

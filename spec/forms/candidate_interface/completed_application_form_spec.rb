require 'rails_helper'

RSpec.describe CandidateInterface::CompletedApplicationForm do
  subject(:completed_application_form) do
    described_class.new(application_form:)
  end

  describe 'validations' do
    context 'when application form is incomplete' do
      let(:application_form) { create(:application_form, :minimum_info) }

      it 'be invalid' do
        expect(completed_application_form).not_to be_valid
      end
    end

    context 'when application form is complete' do
      let(:application_form) { create(:application_form, :completed) }

      it 'be valid' do
        expect(completed_application_form).to be_valid
      end
    end
  end
end

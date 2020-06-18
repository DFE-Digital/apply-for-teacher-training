require 'rails_helper'

RSpec.describe CandidateInterface::ApplyAgainBannerComponent do
  let(:application_form) { create(:completed_application_form) }

  context 'when all course choices have been cancelled' do
    it 'renders component with correct values' do
      create(:application_choice, application_form: application_form, status: 'cancelled')
      create(:application_choice, application_form: application_form, status: 'cancelled')
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Your application has been withdrawn. Do you want to apply again?')
    end
  end

  context 'when some course choices were not cancelled' do
    it 'renders component with correct values' do
      create(:application_choice, application_form: application_form, status: 'cancelled')
      create(:application_choice, :with_rejection, application_form: application_form)
      result = render_inline(described_class.new(application_form: application_form))

      expect(result.text).to include('Do you want to apply again?')
      expect(result.text).not_to include('Your application has been withdrawn.')
    end
  end
end

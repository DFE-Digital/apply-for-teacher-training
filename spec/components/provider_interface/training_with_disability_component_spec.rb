require 'rails_helper'

RSpec.describe ProviderInterface::TrainingWithDisabilityComponent do
  context 'when the candidate has not disclose disability support' do
    it 'renders that no help is required' do
      application_form = instance_double(
        ApplicationForm,
        disclose_disability?: false,
        disability_disclosure: nil,
      )
      result = render_inline(described_class.new(application_form:))
      expect(result.text).to include('Do you want to ask for help to become a teacher?No')
      expect(result.text).not_to include('Give any relevant information')
    end
  end

  context 'when the candidate has disclose disability support' do
    it 'renders the disability disclosure' do
      application_form = instance_double(
        ApplicationForm,
        disclose_disability?: true,
        disability_disclosure: 'I am hard of hearing',
      )
      result = render_inline(described_class.new(application_form:))
      expect(result.text).to include('Do you want to ask for help to become a teacher?Yes, I want to share information about myself so my provider can take steps to support me')
      expect(result.text).to include('Give any relevant informationI am hard of hearing')
    end
  end

  context 'when the candidate has an empty disclose disability support' do
    it 'renders that no help is required' do
      application_form = instance_double(
        ApplicationForm,
        disclose_disability?: true,
        disability_disclosure: '',
      )
      result = render_inline(described_class.new(application_form:))
      expect(result.text).to include('Do you want to ask for help to become a teacher?No')
      expect(result.text).not_to include('Give any relevant information')
    end
  end
end

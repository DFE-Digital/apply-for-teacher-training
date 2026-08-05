require 'rails_helper'

RSpec.describe TrainingWithDisabilityComponent do
  context 'when the candidate has not disclose disability support' do
    it 'renders that no help is required' do
      application_form = instance_double(
        ApplicationForm,
        disclose_disability?: false,
        disability_disclosure: nil,
      )
      result = render_inline(described_class.new(application_form:))
      expect(result.text).to include('Do you want to tell providers about a support need?No')
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
      expect(result.text).to include('Do you want to tell providers about a support need?Yes')
      expect(result.text).to include('Details of your support needsI am hard of hearing')
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
      expect(result.text).to include('Do you want to tell providers about a support need?No')
      expect(result.text).not_to include('Give any relevant information')
    end
  end
end

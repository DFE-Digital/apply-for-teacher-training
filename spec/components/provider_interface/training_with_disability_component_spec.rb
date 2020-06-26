require 'rails_helper'

RSpec.describe ProviderInterface::TrainingWithDisabilityComponent do
  it 'renders `No information shared` if `#disclose_disability` is false' do
    application_form = instance_double(
      ApplicationForm,
      disclose_disability?: false,
      disability_disclosure: nil,
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('No information shared.')
  end

  it 'renders `No information shared` if `#disclose_disability` is true but there is no disclosure' do
    application_form = instance_double(
      ApplicationForm,
      disclose_disability?: true,
      disability_disclosure: '',
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('No information shared.')
  end

  it 'renders `No information shared` if `#disclose_disability` is nil' do
    application_form = instance_double(
      ApplicationForm,
      disclose_disability?: nil,
      disability_disclosure: nil,
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('No information shared.')
  end

  it 'renders disclosure if `#disclose_disability` is true' do
    application_form = instance_double(
      ApplicationForm,
      disclose_disability?: true,
      disability_disclosure: 'I am hard of hearing',
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('I am hard of hearing')
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::TrainingWithDisabilityComponent do
  it 'renders nothing if `#disclose_disability` is false' do
    application_form = instance_double(
      ApplicationForm,
      disclose_disability?: false,
      disability_disclosure: 'I am hard of hearing',
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to eq ''
  end

  it 'renders nothing if `#disclose_disability` is true but there is no disclosure' do
    application_form = instance_double(
      ApplicationForm,
      disclose_disability?: true,
      disability_disclosure: '',
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to eq ''
  end

  it 'renders heading and disclosure if `#disclose_disability` is true' do
    application_form = instance_double(
      ApplicationForm,
      disclose_disability?: true,
      disability_disclosure: 'I am hard of hearing',
    )
    result = render_inline(described_class.new(application_form: application_form))
    expect(result.text).to include('Disability and other needs')
    expect(result.text).to include('I am hard of hearing')
  end
end

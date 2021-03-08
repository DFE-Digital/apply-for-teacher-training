require 'rails_helper'

RSpec.describe ProviderInterface::SelectProviderComponent do
  let(:form_object_class) do
    Class.new do
      include ActiveModel::Model

      attr_accessor :provider_id
    end
  end

  let(:form_object) { FormObjectClass.new(provider_id: selected_provider.id) }
  let(:providers) { build_stubbed_list(:provider, 10) }
  let(:selected_provider) { providers.sample }

  let(:render) do
    render_inline(described_class.new(form_object: form_object,
                                      form_path: '',
                                      providers: providers))
  end

  before do
    stub_const('FormObjectClass', form_object_class)
  end

  it 'renders all providers' do
    expect(render.css('.govuk-radios__item').length).to eq(providers.count)
  end

  it 'selects the preselected provider' do
    expect(render.css('.govuk-radios__item input[checked]').first.next_element.text)
      .to eq(selected_provider.name_and_code)
  end
end

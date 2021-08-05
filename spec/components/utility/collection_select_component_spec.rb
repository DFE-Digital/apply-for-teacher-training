require 'rails_helper'

RSpec.describe CollectionSelectComponent do
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
    render_inline(described_class.new(attribute: :provider_id,
                                      collection: providers,
                                      value_method: :id,
                                      text_method: :name_and_code,
                                      hint_method: nil,
                                      form_object: form_object,
                                      form_path: '',
                                      form_method: :put,
                                      page_title: 'Select provider',
                                      caption: 'Jane Doe'))
  end

  before do
    stub_const('FormObjectClass', form_object_class)
  end

  it 'renders the correct caption' do
    expect(render.css('.govuk-caption-l').text).to eq('Jane Doe')
  end

  it 'renders the correct page title' do
    expect(render.css('.govuk-fieldset__legend').text).to include('Select provider')
  end

  it 'renders all collection items' do
    expect(render.css('.govuk-radios__item').length).to eq(providers.count)
  end

  it 'selects the preselected item' do
    expect(render.css('.govuk-radios__item input[checked]').first.next_element.text)
      .to eq(selected_provider.name_and_code)
  end
end

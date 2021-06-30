require 'rails_helper'

RSpec.describe ProviderInterface::StatusBoxComponent do
  it 'chooses sub-component according to application_choice status' do
    application_choice = instance_double(ApplicationChoice)
    allow(application_choice).to receive(:status).and_return('dummy')

    expect { render_inline(described_class.new(application_choice: application_choice)) }.to \
      raise_error(
        NameError,
        /uninitialized constant ProviderInterface::StatusBoxComponents::DummyComponent/,
      )
  end

  it 'does not render for certain application choice statuses' do
    application_choice = instance_double(ApplicationChoice)
    allow(application_choice).to receive(:status).and_return('withdrawn')

    expect(render_inline(described_class.new(application_choice: application_choice)).to_html).to eq ''
  end
end

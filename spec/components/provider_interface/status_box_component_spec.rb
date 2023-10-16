require 'rails_helper'

RSpec.describe ProviderInterface::StatusBoxComponent do
  let(:application_choice) { build(:application_choice) }

  context 'with an invalid status' do
    before do
      allow(application_choice).to receive(:status).and_return('dummy')
    end

    it 'chooses sub-component according to application_choice status' do
      expect { render_inline(described_class.new(application_choice:)) }.to \
        raise_error(
          NameError,
          /uninitialized constant ProviderInterface::StatusBoxComponents::DummyComponent/,
        )
    end
  end

  context 'with a withdrawn status' do
    before do
      application_choice.inactive!
    end

    it 'does not render for certain application choice statuses' do
      expect(render_inline(described_class.new(application_choice:)).to_html).to eq ''
    end
  end
end

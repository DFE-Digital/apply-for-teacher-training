require 'rails_helper'

RSpec.describe ProviderInterface::SkeConditionsComponent do
  let(:render) do
    render_inline(
      described_class.new(
        'French',
        '12',
        'Their degree subject was not French',
      ),
    )
  end

  it 'renders the selected SKE values' do
    expect(render.to_html).to eq ''
  end
end

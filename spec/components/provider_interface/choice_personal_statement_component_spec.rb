require 'rails_helper'

RSpec.describe ProviderInterface::ChoicePersonalStatementComponent do
  let(:application_choice) do
    build_stubbed(:application_choice, personal_statement: 'I am a personal statement')
  end

  let(:render) { render_inline(described_class.new(application_choice:)) }

  it 'renders the template' do
    expect(render).to have_content('Personal statement')
    expect(render).to have_content('I am a personal statement')
  end
end

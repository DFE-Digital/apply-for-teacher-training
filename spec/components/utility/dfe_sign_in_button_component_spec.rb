require 'rails_helper'

# rubocop:disable RSpec/FilePath
RSpec.describe DfESignInButtonComponent do
  context 'when bypass is set' do
    it 'renders with button with link to the development route' do
      render_result = render_inline(described_class.new(bypass: true))

      expect(render_result.css('form').attr('action').value).to eq '/auth/developer'
      expect(render_result.css('input').attr('value').value).to eq 'Sign in using DfE Sign-in (bypass)'
    end
  end

  context 'when bypass is NOT set' do
    it 'renders with button with link to the development route' do
      render_result = render_inline(described_class.new(bypass: false))

      expect(render_result.css('form').attr('action').value).to eq '/auth/dfe'
      expect(render_result.css('input').attr('value').value).to eq 'Sign in using DfE Sign-in'
    end
  end
end
# rubocop:enable RSpec/FilePath

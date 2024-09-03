require 'rails_helper'

RSpec.describe CandidateInterface::NoDegreeComponent, type: :component do
  let(:component) { described_class.new(application_form:, editable:) }
  let(:application_form) { create(:application_form) }

  subject(:result) { render_inline component }

  context 'when editable' do
    let(:editable) { true }

    it 'renders change link' do
      expect(result.text).to include('Change')
    end
  end

  context 'when not editable' do
    let(:editable) { false }

    it 'does not render change link' do
      expect(result.text).not_to include('Change')
    end
  end
end

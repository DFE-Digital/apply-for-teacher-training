require 'rails_helper'

RSpec.describe SupportInterface::CandidatesTableComponent do
  let(:candidates) { create_list(:candidate, 3) }

  subject(:component) { described_class.new(candidates: candidates) }

  def render_result
    render_inline(described_class, candidates: candidates)
  end

  it 'renders the candidate emails' do
    candidates.collect(&:email_address).each do |email_address|
      expect(render_result.text).to include(email_address)
    end
  end
end

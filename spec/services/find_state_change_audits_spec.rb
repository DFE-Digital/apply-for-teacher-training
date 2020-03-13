require 'rails_helper'

RSpec.describe FindStateChangeAudits do
  context 'for an unsubmitted application' do
    it 'returns an empty array' do
      application_choice = create :application_choice
      result = described_class.new(application_choice: application_choice).call
      expect(result).to eq []
    end
  end

  context 'for a submitted application' do
    it 'returns a single event' do
    end
  end
end

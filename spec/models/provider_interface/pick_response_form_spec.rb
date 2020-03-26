require 'rails_helper'

RSpec.describe ProviderInterface::PickResponseForm do
  describe 'validations' do
    it do
      expect(described_class.new).to validate_inclusion_of(:decision)
        .in_array(described_class::VALID_DECISIONS)
        .with_message('Select if you want to make an offer or reject the application')
    end
  end
end

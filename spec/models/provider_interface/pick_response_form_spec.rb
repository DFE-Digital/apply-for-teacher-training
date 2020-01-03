require 'rails_helper'

RSpec.describe ProviderInterface::PickResponseForm do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:decision).with_message('Select if you want to make an offer or reject the application') }
  end
end

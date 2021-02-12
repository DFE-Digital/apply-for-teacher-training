require 'rails_helper'

RSpec.describe ProviderInterface::CancelInterviewWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore, read: nil) }
  let(:subject) { described_class.new(store) }

  describe '.validations' do
    it { is_expected.to validate_presence_of(:cancellation_reason) }
  end
end

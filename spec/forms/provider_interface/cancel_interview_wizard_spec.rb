require 'rails_helper'

RSpec.describe ProviderInterface::CancelInterviewWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore, read: nil) }
  let(:subject) { described_class.new(store) }

  describe '.validations' do
    valid_text = Faker::Lorem.sentence(word_count: 2000)
    invalid_text = Faker::Lorem.sentence(word_count: 2001)

    it { is_expected.to validate_presence_of(:cancellation_reason) }
    it { is_expected.to allow_value(valid_text).for(:cancellation_reason) }
    it { is_expected.not_to allow_value(invalid_text).for(:cancellation_reason) }
  end
end

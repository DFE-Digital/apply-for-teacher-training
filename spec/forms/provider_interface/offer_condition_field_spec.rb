require 'rails_helper'

RSpec.describe ProviderInterface::OfferConditionField, type: :model do
  subject { described_class.new(id: 0) }

  it { is_expected.to validate_length_of(:text).with_message('Condition 1 must be 255 characters or fewer') }
end

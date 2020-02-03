require 'rails_helper'

RSpec.describe ChaserSent, type: :model do
  it { is_expected.to belong_to(:chased) }
end

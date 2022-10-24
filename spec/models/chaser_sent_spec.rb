require 'rails_helper'

RSpec.describe ChaserSent do
  it { is_expected.to belong_to(:chased) }
end

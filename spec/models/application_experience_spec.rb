require 'rails_helper'

RSpec.describe ApplicationExperience do
  it { is_expected.to belong_to(:experienceable).optional }

  it { is_expected.to validate_presence_of(:role) }
  it { is_expected.to validate_presence_of(:organisation) }
  it { is_expected.to validate_presence_of(:start_date) }
end

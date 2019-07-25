require 'rails_helper'

RSpec.describe Degree, type: :model do
  it { is_expected.to validate_presence_of(:type_of_degree) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_presence_of(:class_of_degree) }
  it { is_expected.to validate_presence_of(:year) }
end

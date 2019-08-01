require 'rails_helper'

RSpec.describe Degree, type: :model do
  let(:current_year) { DateTime.now.year }

  it { is_expected.to validate_presence_of(:type_of_degree) }
  it { is_expected.to validate_presence_of(:subject) }
  it { is_expected.to validate_presence_of(:institution) }
  it { is_expected.to validate_presence_of(:class_of_degree) }
  it { is_expected.to validate_presence_of(:year) }

  it { is_expected.to validate_length_of(:type_of_degree).is_at_most(20) }
  it { is_expected.to validate_length_of(:subject).is_at_most(100) }
  it { is_expected.to validate_length_of(:institution).is_at_most(100) }
  it { is_expected.to validate_length_of(:class_of_degree).is_at_most(20) }

  it { is_expected.to validate_numericality_of(:year).is_greater_than(1899).is_less_than_or_equal_to(current_year) }
end

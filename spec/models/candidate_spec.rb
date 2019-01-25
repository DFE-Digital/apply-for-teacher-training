require 'rails_helper'

RSpec.describe Candidate, type: :model do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:surname) }
  it { should validate_presence_of(:date_of_birth) }
  it { should validate_presence_of(:gender) }

  it { should validate_uniqueness_of(:email).case_insensitive }
end

require 'rails_helper'

RSpec.describe Candidate, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:surname) }
  it { should validate_presence_of(:date_of_birth) }
  it { should validate_presence_of(:gender) }

  describe '#full_name' do
    let(:candidate) { Candidate.new(first_name: 'Bob', surname: 'Smith') }

    it 'should return the full name joined with a space' do
      expect(candidate.full_name).to eq('Bob Smith')
    end
  end
end

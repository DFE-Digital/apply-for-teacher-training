require 'rails_helper'

RSpec.describe CandidatePoolApplication do
  describe 'associations' do
    it { is_expected.to belong_to(:application_form) }
    it { is_expected.to belong_to(:candidate) }
  end
end

require 'rails_helper'

RSpec.describe 'Candidate factory' do
  subject(:record) { |attrs: {}| create(factory, *traits, **attributes, **attrs) }

  let(:traits) { [] }
  let(:attributes) { {} }

  factory :candidate do
    field :email_address, matches: /\A\w+@example\.com\z/
    field :sign_up_email_bounced, value: false
    field :last_signed_in_at, presence: true

    describe 'skip_candidate_api_updated_at' do
      let(:attributes) { { skip_candidate_api_updated_at: true } }

      it 'leaves `candidate_api_updated_at` nil after creation' do
        expect(record.candidate_api_updated_at).to be_nil
      end
    end
  end
end

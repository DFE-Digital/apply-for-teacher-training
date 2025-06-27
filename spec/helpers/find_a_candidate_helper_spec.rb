require 'rails_helper'

RSpec.describe FindACandidateHelper do
  struct = Struct.new(:invited, :viewed)
  let(:application_form) { struct.new(invited:, viewed:) }
  let(:invited) { true }
  let(:viewed) { true }

  describe '#candidate_status' do
    context 'when candidate has been invited' do
      it 'returns the invited tag' do
        candidate_status = helper.candidate_status(application_form:)

        expect(candidate_status).to eq(
          '<strong class="govuk-tag govuk-tag--yellow">Invited</strong>',
        )
      end
    end

    context 'when candidate been viewed' do
      let(:invited) { false }
      let(:viewed) { true }

      it 'returns the viewed tag' do
        candidate_status = helper.candidate_status(application_form:)

        expect(candidate_status).to eq(
          '<strong class="govuk-tag govuk-tag--grey">Viewed</strong>',
        )
      end
    end

    context 'when candidate is new' do
      let(:invited) { false }
      let(:viewed) { false }

      it 'returns the new tag' do
        candidate_status = helper.candidate_status(application_form:)

        expect(candidate_status).to eq(
          '<strong class="govuk-tag">New</strong>',
        )
      end
    end
  end
end

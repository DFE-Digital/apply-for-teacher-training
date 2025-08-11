RSpec.describe CandidateInterface::Invites::DeclineReasonsSuccessFlash::NoLongerInterestedComponent do
  it 'renders the no longer interested message' do
    result = render_inline(described_class.new(invite: build_stubbed(:pool_invite)))

    expect(result).to have_text('You will no longer receive invitations to apply for courses.')
  end
end

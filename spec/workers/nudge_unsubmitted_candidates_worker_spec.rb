require 'rails_helper'

RSpec.describe NudgeUnsubmittedCandidatesWorker, sidekiq: true do
  describe '#perform' do
    context 'when candidate has an unsubmitted completed application' do
      it 'sends email to the candidate'
    end
  end
end

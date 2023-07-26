require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::CourseSelectionStore do
  let(:wizard) do
    CandidateInterface::ContinuousApplications::CourseSelectionWizard.new(
      current_step: :some_step,
    )
  end

  describe '#save' do
    context 'when multiple study modes' do
    end

    context 'when multiple sites' do
    end

    context 'when single site and single study mode' do
    end
  end
end

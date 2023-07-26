require 'rails_helper'

RSpec.describe CandidateInterface::ContinuousApplications::CourseSelectionWizard do
  let(:current_step) { :do_you_know_the_course }

  subject(:wizard) do
    described_class.new(current_step:)
  end

  describe '#info' do
    before do
      allow(Rails.logger).to receive(:info)
    end

    context 'when production environment' do
      it 'do not log' do
        allow(Rails).to receive(:env).and_return(
          ActiveSupport::EnvironmentInquirer.new('production'),
        )
        wizard.info('DfE::Wizard')
        expect(Rails.logger).not_to have_received(:info)
      end
    end

    context 'when development environment' do
      it 'do log' do
        allow(Rails).to receive(:env).and_return(
          ActiveSupport::EnvironmentInquirer.new('development'),
        )
        wizard.info('DfE::Wizard')
        expect(Rails.logger).to have_received(:info)
      end
    end

    context 'when testing environment' do
      it 'do log' do
        allow(Rails).to receive(:env).and_return(
          ActiveSupport::EnvironmentInquirer.new('test'),
        )
        wizard.info('DfE::Wizard')
        expect(Rails.logger).to have_received(:info)
      end
    end
  end
end

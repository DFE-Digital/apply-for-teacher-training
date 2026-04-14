require 'rails_helper'

RSpec.describe CandidateInterface::CourseChoices::CourseSelectionWizard do
  let(:current_step) { :do_you_know_the_course }
  let(:application_choice) { build(:application_choice) }
  let(:step_params) { {} }

  subject(:wizard) do
    described_class.new(
      current_step:,
      application_choice:,
      step_params:,
    )
  end

  describe '#info' do
    before do
      allow(Rails.logger).to receive(:info)
    end

    context 'when production environment' do
      it 'do not log' do
        allow(HostingEnvironment).to receive(:environment_name).and_return(
          'production',
        )
        wizard.info('DfE::Wizard')
        expect(Rails.logger).not_to have_received(:info)
      end
    end

    context 'when development environment' do
      it 'do log' do
        allow(HostingEnvironment).to receive(:environment_name).and_return(
          'development',
        )
        wizard.info('DfE::Wizard')
        expect(Rails.logger).to have_received(:info)
      end
    end

    context 'when qa environment' do
      it 'do log' do
        allow(HostingEnvironment).to receive(:environment_name).and_return(
          'qa',
        )
        wizard.info('DfE::Wizard')
        expect(Rails.logger).to have_received(:info)
      end
    end

    context 'when testing environment' do
      it 'do log' do
        allow(HostingEnvironment).to receive(:environment_name).and_return(
          'test',
        )
        wizard.info('DfE::Wizard')
        expect(Rails.logger).to have_received(:info)
      end
    end
  end

  describe '#update_visa_explanation' do
    context 'when visa_explanation step is valid' do
      let(:current_step) { :visa_explanation }
      let(:application_choice) { create(:application_choice) }
      let(:step_params) do
        ActionController::Parameters.new(
          {
            visa_explanation: {
              visa_explanation: 'other',
              visa_explanation_details: 'I will renew my visa',
              application_choice_id: application_choice.id,
            },
          },
        )
      end

      it 'updates the visa_explanation' do
        expect { wizard.update_visa_explanation }.to change {
          application_choice.visa_explanation
        }.from(nil).to('other')
        expect(wizard.update_visa_explanation).to be(true)
      end
    end

    context 'when visa_explanation step is invalid' do
      let(:current_step) { :visa_explanation }
      let(:application_choice) { create(:application_choice) }
      let(:step_params) do
        ActionController::Parameters.new(
          {
            visa_explanation: {
              visa_explanation: 'other',
              application_choice_id: application_choice.id,
            },
          },
        )
      end

      it 'does not update the visa_explanation' do
        expect { wizard.update_visa_explanation }.not_to change {
          application_choice.visa_explanation
        }.from(nil)
        expect(wizard.update_visa_explanation).to be(false)
      end
    end

    context 'current step is not visa_explanation' do
      let(:current_step) { :course_site }
      let(:application_choice) { create(:application_choice) }
      let(:step_params) do
        ActionController::Parameters.new(
          {
            visa_explanation: {
              visa_explanation: 'other',
              visa_explanation_details: 'I will renew my visa',
              application_choice_id: application_choice.id,
            },
          },
        )
      end

      it 'does not update the visa_explanation' do
        expect { wizard.update_visa_explanation }.not_to change {
          application_choice.visa_explanation
        }.from(nil)
        expect(wizard.update_visa_explanation).to be(false)
      end
    end
  end
end

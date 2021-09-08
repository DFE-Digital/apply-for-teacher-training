require 'rails_helper'

RSpec.describe InterviewPathHelper do
  let(:application_choice) { build_stubbed(:application_choice) }
  let(:wizard) { instance_double(ProviderInterface::InterviewWizard, referer: 'referer-url') }
  let!(:interview) { build_stubbed(:interview) }

  describe '#interview_path_for' do
    context 'when mode is :input' do
      it 'returns the new interview path' do
        expect(helper.interview_path_for(application_choice, wizard, nil, 'input'))
          .to eq(new_provider_interface_application_choice_interview_path(application_choice, {}))
      end
    end

    context 'when mode is :edit' do
      it 'returns the edit interview path' do
        expect(helper.interview_path_for(application_choice, wizard, interview, 'edit'))
          .to eq(edit_provider_interface_application_choice_interview_path(application_choice, interview, {}))
      end
    end

    context 'when mode is :check' do
      context 'when there is no existing interview' do
        it 'returns the collection check path' do
          expect(helper.interview_path_for(application_choice, wizard, nil, 'check'))
            .to eq(new_provider_interface_interviews_check_path(application_choice, {}))
        end
      end

      context 'when there is an existing interview' do
        it 'returns the interview check path' do
          expect(helper.interview_path_for(application_choice, wizard, interview, 'check'))
            .to eq(edit_provider_interface_application_choice_interview_check_path(application_choice, interview, {}))
        end
      end
    end
  end
end

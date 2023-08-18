require 'rails_helper'

RSpec.describe BackLinks do
  let(:application_form) { create(:application_form) }
  let(:candidate) { application_form.candidate }
  let(:routes) { Rails.application.routes.url_helpers }
  let(:request) { ActionDispatch::TestRequest.create }

  describe '#application_form_path' do
    before do
      stub_const('BackLinkController', Class.new(CandidateInterface::CandidateInterfaceController) { include BackLinks })
      allow(instance).to receive_messages(current_application: application_form, current_candidate: candidate)
      instance.set_request!(request)
    end

    let(:instance) { BackLinkController.new }

    context 'with legacy applications' do
      it 'excludes deferrals' do
        expect(instance.send(:application_form_path)).to eq routes.candidate_interface_application_form_path
      end
    end

    context 'with submitted applications' do
      let(:application_form) { create(:application_form, :submitted) }

      it 'returns path to review submitted' do
        expect(instance.send(:application_form_path)).to eq routes.candidate_interface_application_review_submitted_path
      end
    end

    describe 'continuous applications', continuous_applications: true do
      context 'default application home' do
        let(:application_form) { create(:application_form) }

        it 'returns path to application details' do
          expect(instance.send(:application_form_path)).to eq routes.candidate_interface_continuous_applications_details_path
        end
      end

      context 'when referer matches "withdraw"' do
        let(:application_form) { create(:application_form) }

        before do
          request.set_header('PATH_INFO', routes.candidate_interface_withdraw_path(1))
        end

        it 'returns path to application details' do
          expect(instance.send(:application_form_path)).to eq routes.candidate_interface_continuous_applications_choices_path
        end
      end
    end
  end
end

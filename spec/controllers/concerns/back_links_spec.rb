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

    context 'default application home' do
      let(:application_form) { create(:application_form) }

      it 'returns path to application details' do
        expect(instance.send(:application_form_path)).to eq routes.candidate_interface_details_path
      end
    end

    context 'when referer matches "withdraw"' do
      let(:application_form) { create(:application_form) }

      before do
        request.set_header('PATH_INFO', routes.candidate_interface_withdrawal_reasons_level_one_reason_new_path(1))
      end

      it 'returns path to application choices' do
        expect(instance.send(:application_form_path)).to eq routes.candidate_interface_application_choices_path
      end
    end
  end
end

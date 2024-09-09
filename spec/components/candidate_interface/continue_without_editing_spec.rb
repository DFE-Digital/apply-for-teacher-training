require 'rails_helper'

RSpec.describe CandidateInterface::ContinueWithoutEditing, type: :component do
  include Rails.application.routes.url_helpers
  let(:application_choice) { create(:application_choice, application_form: current_application) }
  let(:current_application) { create(:application_form) }

  subject(:component) do
    render_inline(
      described_class.new(
        current_application:,
        application_choice:,
      ),
    )
  end

  describe '#continue_without_editing' do
    context 'when application_choice has an undergraduate course and application form has a degree' do
      before do
        allow(application_choice).to receive(:undergraduate_course_and_application_form_with_degree?).and_return(true)
      end

      it 'renders the undergraduate interruption path' do
        expect(component.css('a').attribute('href').value).to eq(
          candidate_interface_course_choices_course_review_undergraduate_interruption_path(application_choice.id),
        )
      end
    end

    context 'when qualifications ENIC reasons are waiting or maybe' do
      before do
        allow(application_choice).to receive(:undergraduate_course_and_application_form_with_degree?).and_return(false)
        allow(current_application).to receive(:qualifications_enic_reasons_waiting_or_maybe?).and_return(true)
      end

      it 'renders the ENIC interruption path' do
        expect(component.css('a').attribute('href').value).to eq(
          candidate_interface_course_choices_course_review_enic_interruption_path(application_choice.id),
        )
      end
    end

    context 'when ENIC reasons are not needed' do
      before do
        allow(application_choice).to receive(:undergraduate_course_and_application_form_with_degree?).and_return(false)
        allow(current_application).to receive_messages(qualifications_enic_reasons_waiting_or_maybe?: false, any_qualification_enic_reason_not_needed?: true)
      end

      it 'renders the ENIC interruption path' do
        expect(component.css('a').attribute('href').value).to eq(
          candidate_interface_course_choices_course_review_enic_interruption_path(application_choice.id),
        )
      end
    end

    context 'when no special conditions are met' do
      before do
        allow(application_choice).to receive(:undergraduate_course_and_application_form_with_degree?).and_return(false)
        allow(current_application).to receive_messages(qualifications_enic_reasons_waiting_or_maybe?: false, any_qualification_enic_reason_not_needed?: false)
      end

      it 'renders the review and submit path' do
        expect(component.css('a').attribute('href').value).to eq(
          candidate_interface_course_choices_course_review_and_submit_path(application_choice.id),
        )
      end
    end
  end
end

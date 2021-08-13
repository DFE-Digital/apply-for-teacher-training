require 'rails_helper'

RSpec.describe CandidateInterface::SelectedReferencesComponent, type: :component do
  context 'when references section is completed' do
    # The component only checks ApplicationForm#references_completed?, and
    # expects that the correct number of reference selections are present if
    # this boolean is true.
    it 'renders selected references' do
      application = create(:application_form, references_completed: true)
      reference1 = create(:reference, :feedback_provided, selected: true, application_form: application)
      reference2 = create(:reference, :feedback_provided, selected: true, application_form: application)

      render_inline(described_class.new(application)).to_html

      expect(page).to have_content(reference1.name)
      expect(page).to have_content(reference2.name)
    end
  end

  context 'when references section is not completed' do
    let(:application) { create(:application_form, references_completed: false) }

    context 'and `editable` and `show_incomplete` are false' do
      it 'simply renders the summary table' do
        render_inline(described_class.new(application, editable: false, show_incomplete: false))

        expect(page).to have_css '.app-summary-card'
        expect(page).to have_content 'Selected references'
      end
    end

    context 'and `editable` and `show_incomplete` are true' do
      let(:render) { render_inline(described_class.new(application, editable: true, show_incomplete: true)) }

      context 'and no references exist on the application' do
        it 'warns that not enough references received and links to the appropriate page' do
          render
          expect(page).to have_link(
            'You need to receive at least 2 references',
            href: url_helpers.candidate_interface_references_review_path,
          )
        end
      end

      context 'and the minimum number of references has not been received' do
        before do
          create(:reference, :feedback_requested, selected: false, application_form: application)
          create(:reference, :feedback_requested, selected: false, application_form: application)
        end

        it 'warns that not enough references received and links to the appropriate page' do
          render
          expect(page).to have_link(
            'You need to receive at least 2 references',
            href: url_helpers.candidate_interface_references_review_path,
          )
        end
      end

      context 'and the required number of references has not been selected' do
        before do
          create(:reference, :feedback_provided, selected: false, application_form: application)
          create(:reference, :feedback_provided, selected: false, application_form: application)
        end

        it 'warns that not enough references selected and links to the appropriate page ' do
          render
          expect(page).to have_link(
            'You need to select 2 references',
            href: url_helpers.candidate_interface_select_references_path,
          )
        end
      end

      context 'when enough references selected' do
        before do
          create(:reference, :feedback_provided, selected: true, application_form: application)
          create(:reference, :feedback_provided, selected: true, application_form: application)
        end

        it 'warns that the section is incomplete and links to the appropriate page' do
          render
          expect(page).to have_link(
            'Complete your references',
            href: url_helpers.candidate_interface_review_selected_references_path,
          )
        end
      end
    end
  end

private

  def url_helpers
    Rails.application.routes.url_helpers
  end
end

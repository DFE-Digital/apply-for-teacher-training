require 'rails_helper'

RSpec.describe CandidateInterface::NewReferencesReviewComponent, type: :component do
  let(:application_form) { create(:application_form) }

  context 'when on application review page' do
    context 'when application has zero references' do
      it 'renders add references message' do
        result = render_inline(described_class.new(application_form: application_form, references: []))

        expect(result.text).to include(I18n.t('review_application.new_references.not_entered'))
        expect(result.css('a').map(&:text)).to include(I18n.t('review_application.new_references.enter_references'))
      end
    end

    context 'when application has one references' do
      it 'renders add references message' do
        reference = create(:reference, :not_requested_yet, application_form: application_form)
        result = render_inline(described_class.new(application_form: application_form, references: [reference]))

        expect(result.text).to include(I18n.t('review_application.new_references.one_reference_only'))
        expect(result.css('a').map(&:text)).to include(I18n.t('review_application.new_references.add_more_references'))
      end
    end

    context 'when application has two references but references section is incomplete' do
      it 'renders incomplete message' do
        application_form = create(:application_form, references_completed: false)
        create_list(:reference, 2, :feedback_provided, application_form: application_form)
        result = render_inline(described_class.new(application_form: application_form, references: application_form.application_references))

        expect(result.text).to include(I18n.t('review_application.new_references.incomplete'))
        expect(result.css('a').map(&:text)).to include(I18n.t('review_application.new_references.complete_section'))
      end
    end

    context 'when references section is complete' do
      it 'does not render any error message' do
        application_form = create(:application_form, :with_completed_references, references_completed: true)
        create_list(:reference, 2, :feedback_provided, application_form: application_form)
        result = render_inline(described_class.new(application_form: application_form, references: application_form.application_references))

        expect(result.text).not_to include(I18n.t('review_application.new_references.incomplete'))
      end
    end
  end

  context 'when on review page' do
    context 'when application has zero references' do
      it 'does not render any error link' do
        result = render_inline(described_class.new(application_form: application_form, references: [], editable: false))

        expect(result.css('a').map(&:text)).not_to include(I18n.t('review_application.new_references.enter_references'))
      end
    end

    it 'renders the referee name and email' do
      reference = create(:reference, :not_requested_yet, application_form: application_form)
      result = render_inline(described_class.new(application_form: application_form, references: [reference]))

      name_row = result.css('.govuk-summary-list__row')[1].text
      email_row = result.css('.govuk-summary-list__row')[2].text
      expect(name_row).to include 'Name'
      expect(name_row).to include reference.name
      expect(email_row).to include 'Email'
      expect(email_row).to include reference.email_address
    end

    it 'renders the reference type' do
      reference = create(:reference, :not_requested_yet, referee_type: :school_based, application_form: application_form)
      result = render_inline(described_class.new(references: [reference], application_form: application_form))

      type_row = result.css('.govuk-summary-list__row')[0].text
      expect(type_row).to include 'Type'
      expect(type_row).to include 'School-based'
    end

    it 'renders the relationship' do
      reference = create(:reference, :not_requested_yet, application_form: application_form)
      result = render_inline(described_class.new(references: [reference], application_form: application_form))

      relationship_row = result.css('.govuk-summary-list__row')[3].text
      expect(relationship_row).to include 'Relationship to you'
      expect(relationship_row).to include reference.relationship
    end

    it 'renders all references passed in' do
      reference_one = create(:reference, application_form: application_form)
      reference_two = create(:reference, application_form: application_form)

      result = render_inline(described_class.new(references: [reference_one, reference_two], application_form: application_form))
      expect(result.text).to include reference_one.email_address
      expect(result.text).to include reference_two.email_address
    end

    context 'when a reference is carried over' do
      context 'when the state is feedback_provided' do
        it 'renders a status row' do
          reference = create(:reference, :feedback_provided, application_form: application_form)
          result = render_inline(described_class.new(references: [reference], application_form: application_form))

          status_row = result.css('.govuk-summary-list__row')[4].text
          expect(status_row).to include 'Status'
          expect(status_row).to include 'Reference received'
          expect(status_row).to include "#{reference.name} will not be asked to give you another reference."
        end
      end

      context 'when the state is not feedback_provided' do
        it 'does not render a status row' do
          reference = create(:reference, :feedback_requested, application_form: application_form)
          result = render_inline(described_class.new(references: [reference], application_form: application_form))

          status_row = result.css('.govuk-summary-list__row')[4]
          expect(status_row).to be_nil
        end
      end
    end
  end
end

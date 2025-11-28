require 'rails_helper'

RSpec.describe CandidateInterface::ReferencesReviewComponent, type: :component do
  let(:application_form) { create(:application_form) }

  context 'when on application review page' do
    let(:references) { [] }
    let(:component) do
      described_class.new(
        application_form:,
        application_choice: application_form.application_choices.first,
        references:,
        return_to_application_review: true,
      )
    end

    context 'when application has zero references' do
      it 'displays reference guidance' do
        render_inline(component) do |result|
          expect(result).to have_element(
            :p,
            text: 'When you accept your offer, we’ll send emails to the people you said could give you references.',
          )
          expect(result).to have_element(
            :p,
            text: 'Until we email them you can change any details about them.',
          )
          expect(result).to have_element(
            :p,
            text: 'After we have emailed them you will not be able to make any changes.',
          )
        end
      end

      it 'renders add references message' do
        render_inline(component) do |result|
          expect(result.text).to include(I18n.t('review_application.references.not_entered'))
          expect(result.css('a').map(&:text)).to include(I18n.t('review_application.references.enter_references'))
        end
      end
    end

    context 'when application has one references' do
      let(:references) do
        [create(:reference, :not_requested_yet, application_form:)]
      end

      it 'displays reference guidance' do
        render_inline(component) do |result|
          expect(result).to have_element(
            :p,
            text: 'When you accept your offer, we’ll send emails to the people you said could give you references.',
          )
          expect(result).to have_element(
            :p,
            text: 'Until we email them you can change any details about them.',
          )
          expect(result).to have_element(
            :p,
            text: 'After we have emailed them you will not be able to make any changes.',
          )
        end
      end

      it 'renders add references message' do
        render_inline(component) do |result|
          expect(result.text).to include(I18n.t('review_application.references.one_reference_only'))
          expect(result.css('a').map(&:text)).to include(I18n.t('review_application.references.add_more_references'))
        end
      end
    end

    context 'when application has two references but references section is incomplete' do
      let(:application_form) { create(:application_form, references_completed: false) }
      let(:references) do
        create_list(:reference, 2, :feedback_provided, application_form:)
      end

      it 'renders incomplete message' do
        render_inline(component) do |result|
          expect(result.text).to include(I18n.t('review_application.references.incomplete'))
          expect(result.css('a').map(&:text)).to include(I18n.t('review_application.references.complete_section'))
        end
      end
    end

    context 'when references section is complete' do
      it 'does not render any error message' do
        application_form = create(:application_form, :with_completed_references, references_completed: true)
        create_list(:reference, 2, :feedback_provided, application_form:)
        result = render_inline(described_class.new(application_form:, references: application_form.application_references))

        expect(result.text).not_to include(I18n.t('review_application.references.incomplete'))
      end
    end
  end

  context 'when on review page' do
    context 'when application has zero references' do
      it 'does not render any error link' do
        result = render_inline(described_class.new(application_form:, references: [], editable: false))

        expect(result.css('a').map(&:text)).not_to include(I18n.t('review_application.references.enter_references'))
      end
    end

    it 'renders the referee name and email' do
      reference = create(:reference, :not_requested_yet, application_form:)
      result = render_inline(described_class.new(application_form:, references: [reference]))

      name_row = result.css('.govuk-summary-list__row')[1].text
      email_row = result.css('.govuk-summary-list__row')[2].text
      expect(name_row).to include 'Name'
      expect(name_row).to include reference.name
      expect(email_row).to include 'Email'
      expect(email_row).to include reference.email_address
    end

    it 'renders the reference type' do
      reference = create(:reference, :not_requested_yet, referee_type: :school_based, application_form:)
      result = render_inline(described_class.new(references: [reference], application_form:))

      type_row = result.css('.govuk-summary-list__row')[0].text
      expect(type_row).to include 'Type'
      expect(type_row).to include 'School experience, such as from the headteacher of a school you have been working in'
    end

    it 'renders the relationship' do
      reference = create(:reference, :not_requested_yet, application_form:)
      result = render_inline(described_class.new(references: [reference], application_form:))

      relationship_row = result.css('.govuk-summary-list__row')[3].text
      expect(relationship_row).to include 'How you know them and for how long'
      expect(relationship_row).to include reference.relationship
    end

    it 'renders all references passed in' do
      reference_one = create(:reference, application_form:)
      reference_two = create(:reference, application_form:)

      result = render_inline(described_class.new(references: [reference_one, reference_two], application_form:))
      expect(result.text).to include reference_one.email_address
      expect(result.text).to include reference_two.email_address
    end

    it 'renders the delete link' do
      reference = create(:reference, application_form:)

      result = render_inline(described_class.new(references: [reference], application_form:))
      expect(result.css("a[href='#{delete_reference_path(reference)}']")).to be_present
    end

    context 'when a reference is carried over' do
      it 'does not render the delete link' do
        reference = create(:reference, application_form:, duplicate: true)

        result = render_inline(described_class.new(references: [reference], application_form:))
        expect(result.css("a[href='#{delete_reference_path(reference)}']")).not_to be_present
      end

      context 'when the state is feedback_provided' do
        it 'renders a status row' do
          reference = create(:reference, :feedback_provided, application_form:)
          result = render_inline(described_class.new(references: [reference], application_form:))

          status_row = result.css('.govuk-summary-list__row')[4].text
          expect(status_row).to include "#{reference.name} has already given a reference."
          expect(status_row).to include 'If you accept an offer, the training provider will see the reference.'

          expect(result).to have_element(:strong, text: 'Received', class: 'govuk-tag govuk-tag--green')
        end
      end

      context 'when the state is not feedback_provided' do
        it 'does not render a status row' do
          reference = create(:reference, :feedback_requested, application_form:)
          result = render_inline(described_class.new(references: [reference], application_form:))

          status_row = result.css('.govuk-summary-list__row')[4]
          expect(status_row).to be_nil

          expect(result).to have_element(:strong, text: 'Requested', class: 'govuk-tag govuk-tag--orange')
        end
      end
    end
  end

  def delete_reference_path(reference)
    Rails.application.routes.url_helpers.candidate_interface_confirm_destroy_new_reference_path(reference)
  end
end

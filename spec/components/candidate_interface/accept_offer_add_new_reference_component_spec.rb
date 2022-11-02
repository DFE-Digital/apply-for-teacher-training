require 'rails_helper'

RSpec.describe CandidateInterface::AcceptOfferAddNewReferenceComponent do
  it 'add focus link' do
    application_form = create(:application_form)
    application_choice = create(:application_choice, application_form:)
    result = render_inline(described_class.new(application_form:, application_choice:))
    expect(result.css('#accept-offer-add-new-reference-field')).to be_present
  end

  context 'when application has zero references' do
    it 'renders primary button' do
      application_form = create(:application_form)
      application_choice = create(:application_choice, application_form:)
      result = render_inline(described_class.new(application_form:, application_choice:))

      expect(result.text).to include(I18n.t('application_form.references.add_reference.zero'))
      expect(result.css('a', text: I18n.t('application_form.references.add_reference.zero')).first[:class]).to eq('govuk-button')
    end
  end

  context 'when application has one reference' do
    it 'renders primary button' do
      application_form = create(:application_form)
      create(:reference, :not_requested_yet, application_form:)
      application_choice = create(:application_choice, application_form:)
      result = render_inline(described_class.new(application_form:, application_choice:))

      expect(result.text).to include(I18n.t('application_form.references.add_reference.one'))
      expect(result.css('a', text: I18n.t('application_form.references.add_reference.zero')).first[:class]).to eq('govuk-button')
    end
  end

  context 'when application has two references' do
    it 'renders secondary button' do
      application_form = create(:application_form)
      create_list(:reference, 2, :not_requested_yet, application_form:)
      application_choice = create(:application_choice, application_form:)
      result = render_inline(described_class.new(application_form:, application_choice:))

      expect(result.text).to include(I18n.t('application_form.references.add_reference.other'))
      expect(result.css('a', text: I18n.t('application_form.references.add_reference.zero')).first[:class]).to eq('govuk-button govuk-button--secondary')
    end
  end
end

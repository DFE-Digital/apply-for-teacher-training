require 'rails_helper'

RSpec.describe RefereeInterface::ReferenceReviewComponent do
  context 'when there is no relationship correction' do
    let(:reference) { build_stubbed(:reference, relationship_correction: '', relationship: 'They were my lecturer.') }

    it 'displays that the relationship is confirmed' do
      result = render_inline(described_class.new(reference:))

      expect(result.css('.govuk-summary-list__key').text).to include('How they know you')
      expect(result.css('.govuk-summary-list__value').text).to include("You confirmed their description of how they know you:\n\nThey were my lecturer.")
      expect(result.css('.govuk-summary-list__value').text).not_to include('You said this is how you know them:')
    end
  end

  context 'when there is a relationship correction' do
    let(:reference) { build_stubbed(:reference, relationship_correction: 'meh') }

    it 'displays the correction' do
      result = render_inline(described_class.new(reference:))

      expect(result.css('.govuk-summary-list__key').text).to include('How you know them')
      expect(result.css('.govuk-summary-list__value').text).to include("You said this is how you know them:\n\nmeh")
    end
  end

  context 'when there is no safeguarding concern' do
    let(:reference) { build_stubbed(:reference, safeguarding_concerns: '', safeguarding_concerns_status: :no_safeguarding_concerns_to_declare) }

    it 'displays that there are no concerns about safeguarding' do
      result = render_inline(described_class.new(reference:))

      expect(result.css('.govuk-summary-list__key').text).to include('Concerns about them working with children')
      expect(result.css('.govuk-summary-list__value').text).to include('You have no concerns.')
    end
  end

  context 'when there is no answer to safeguarding concerns' do
    let(:reference) { build_stubbed(:reference, safeguarding_concerns: nil) }

    it 'displays that there are no concerns about safeguarding' do
      result = render_inline(described_class.new(reference:))

      expect(result.css('.govuk-summary-list__key').text).to include('Concerns about them working with children')
      expect(result.css('.govuk-summary-list__value').text).to include('Not answered')
    end
  end

  context 'when there are safeguarding concerns' do
    let(:reference) do
      build_stubbed(
        :reference,
        safeguarding_concerns: 'very very concerned',
        safeguarding_concerns_status: :has_safeguarding_concerns_to_declare,
      )
    end

    it 'displays the safeguarding concerns' do
      result = render_inline(described_class.new(reference:))

      expect(result.css('.govuk-summary-list__key').text).to include('Concerns about them working with children')
      expect(result.css('.govuk-summary-list__value').text).to include('very very concerned')
    end
  end

  context 'when there is reference' do
    let(:reference) { build_stubbed(:reference, feedback: 'best MS paint artist in the world') }

    it 'displays the safeguarding concerns' do
      result = render_inline(described_class.new(reference:))

      expect(result.css('.govuk-summary-list__key').text).to include('Reference')
      expect(result.css('.govuk-summary-list__value').text).to include('best MS paint artist in the world')
    end
  end

  context 'when editable' do
    it 'displays the change links' do
      result = render_inline(described_class.new(reference: build_stubbed(:reference, relationship_correction: '')))

      expect(result.text).to include('Change your confirmation of how they know you')
      expect(result.text).to include('Change concerns about them working with children')
      expect(result.text).to include('Change reference')
    end
  end

  context 'when editable and you gave a different description' do
    it 'displays the change links' do
      result = render_inline(described_class.new(reference: build_stubbed(:reference, relationship_correction: 'They were my student')))

      expect(result.text).to include('Change how you know them')
    end
  end

  context 'when not editable' do
    it 'does not display the change links' do
      result = render_inline(described_class.new(reference: build_stubbed(:reference), editable: false))

      expect(result.text).not_to include('Change relationship')
      expect(result.text).not_to include('Change concerns about them working with children')
      expect(result.text).not_to include('Change reference')
    end
  end
end

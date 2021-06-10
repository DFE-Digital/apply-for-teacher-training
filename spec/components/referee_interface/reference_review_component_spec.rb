require 'rails_helper'

RSpec.describe RefereeInterface::ReferenceReviewComponent do
  context 'when there is no relationship correction' do
    let(:reference) { build_stubbed(:reference, relationship_correction: '') }

    it 'displays that the relationship is confirmed' do
      result = render_inline(described_class.new(reference: reference))

      expect(result.css('.govuk-summary-list__key').text).to include('Relationship')
      expect(result.css('.govuk-summary-list__value').text).to include('You’ve confirmed your relationship with the candidate')
    end
  end

  context 'when there is a relationship correction' do
    let(:reference) { build_stubbed(:reference, relationship_correction: 'meh') }

    it 'displays the correction' do
      result = render_inline(described_class.new(reference: reference))

      expect(result.css('.govuk-summary-list__key').text).to include('Relationship')
      expect(result.css('.govuk-summary-list__value').text).to include('Amended by referee to: meh')
    end
  end

  context 'when there is no safeguarding concern' do
    let(:reference) { build_stubbed(:reference, safeguarding_concerns: '') }

    it 'displays that there are no concerns about safeguarding' do
      result = render_inline(described_class.new(reference: reference))

      expect(result.css('.govuk-summary-list__key').text).to include('Concerns about candidate working with children')
      expect(result.css('.govuk-summary-list__value').text).to include('No')
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
      result = render_inline(described_class.new(reference: reference))

      expect(result.css('.govuk-summary-list__key').text).to include('Concerns about candidate working with children')
      expect(result.css('.govuk-summary-list__value').text).to include('very very concerned')
    end
  end

  context 'when there is reference' do
    let(:reference) { build_stubbed(:reference, feedback: 'best MS paint artist in the world') }

    it 'displays the safeguarding concerns' do
      result = render_inline(described_class.new(reference: reference))

      expect(result.css('.govuk-summary-list__key').text).to include('Reference')
      expect(result.css('.govuk-summary-list__value').text).to include('best MS paint artist in the world')
    end
  end

  context 'when editable' do
    it 'displays the change links' do
      result = render_inline(described_class.new(reference: build_stubbed(:reference)))

      expect(result.text).to include('Change relationship')
      expect(result.text).to include('Change concerns about candidate working with children')
      expect(result.text).to include('Change reference')
    end
  end

  context 'when not editable' do
    it 'does not display the change links' do
      result = render_inline(described_class.new(reference: build_stubbed(:reference), editable: false))

      expect(result.text).not_to include('Change relationship')
      expect(result.text).not_to include('Change concerns about candidate working with children')
      expect(result.text).not_to include('Change reference')
    end
  end
end

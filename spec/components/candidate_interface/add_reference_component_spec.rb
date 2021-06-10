require 'rails_helper'

RSpec.describe CandidateInterface::AddReferenceComponent do
  let(:application_form) { create(:application_form) }

  context 'when the candidate has no viable references' do
    it 'renders successfully' do
      create(:reference, :feedback_refused, application_form: application_form)

      result = render_inline(described_class.new(application_form))

      expect(link_text(result)).to eq 'Add a referee'
      expect(href(result)).to eq '/candidate/application/references/start'
      expect(body_text(result)).to eq 'You need 2 references before you can submit your application.'
    end
  end

  context 'when the candidate has one viable reference' do
    it 'renders successfully' do
      create(:reference, :feedback_refused, application_form: application_form)
      create(:reference, :not_requested_yet, application_form: application_form)

      result = render_inline(described_class.new(application_form))

      expect(link_text(result)).to eq 'Add a second referee'
      expect(href(result)).to eq '/candidate/application/references/start'
      expect(body_text(result)).to eq 'You need 2 references before you can submit your application.'
    end
  end

  context 'when the candidate has two or more viable references' do
    it 'renders successfully' do
      create(:reference, :feedback_requested, application_form: application_form)
      create(:reference, :feedback_provided, application_form: application_form)

      result = render_inline(described_class.new(application_form))

      expected_first_para = 'You can add more referees to increase the chances of getting 2 references quickly.'
      expected_second_para = 'We’ll cancel any remaining requests when you’ve received 2 references.'

      expect(link_text(result)).to eq 'Add another referee'
      expect(href(result)).to eq '/candidate/application/references/start'
      if FeatureFlag.active?(:reference_selection)
        expect(body_text(result)).to eq expected_first_para
      else
        expect(body_text(result)).to eq expected_first_para + expected_second_para
      end
    end
  end

  context 'when reference_selection feature is off' do
    before { FeatureFlag.deactivate(:reference_selection) }

    context 'and enough references have been provided' do
      it 'does not render any content' do
        create(:reference, :feedback_provided, application_form: application_form)
        create(:reference, :feedback_provided, application_form: application_form)

        result = render_inline(described_class.new(application_form))

        expect(link(result)).to be_empty
        expect(body_text(result)).to be_empty
      end
    end
  end

  context 'when reference_selection feature is on' do
    before { FeatureFlag.activate(:reference_selection) }

    context 'and minimum required references have been provided' do
      it 'renders the correct content' do
        create(:reference, :feedback_provided, application_form: application_form)
        create(:reference, :feedback_provided, application_form: application_form)

        result = render_inline(described_class.new(application_form))
        expect(link_text(result)).to eq 'Add another referee'
        expect(href(result)).to eq '/candidate/application/references/start'
        expect(body_text(result)).to eq 'You can add as many referees as you like but you can only submit 2 with your application.'
      end
    end
  end

private

  def link(result)
    result.css('a')
  end

  def link_text(result)
    result.css('a').first.text
  end

  def href(result)
    result.css('a').first.attributes['href'].value
  end

  def body_text(result)
    result.css('.govuk-body').text
  end
end

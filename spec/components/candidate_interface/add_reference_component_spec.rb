require 'rails_helper'

RSpec.describe CandidateInterface::AddReferenceComponent do
  let(:application_form) { create(:application_form) }

  context 'when the candidate has no viable references' do
    it 'renders successfully' do
      create(:reference, :feedback_refused, application_form: application_form)

      result = render_inline(described_class.new(application_form))

      expect(link_text(result)).to eq 'Request a reference'
      expect(href(result)).to eq '/candidate/application/references/start'
      expect(body_text(result)).to eq 'You need to get 2 references back before you can submit your application.'
    end
  end

  context 'when the candidate has one viable reference' do
    it 'renders successfully' do
      create(:reference, :feedback_refused, application_form: application_form)
      create(:reference, :not_requested_yet, application_form: application_form)

      result = render_inline(described_class.new(application_form))

      expect(link_text(result)).to eq 'Request a second reference'
      expect(href(result)).to eq '/candidate/application/references/start'
      expect(body_text(result)).to eq 'You need to get 2 references back before you can submit your application.'
    end
  end

  context 'when the candidate has two or more viable references' do
    it 'renders successfully' do
      create(:reference, :feedback_requested, application_form: application_form)
      create(:reference, :feedback_provided, application_form: application_form)

      result = render_inline(described_class.new(application_form))

      expected_first_para = 'You can add more referees to increase the chances of getting 2 references quickly.'

      expect(link_text(result)).to eq 'Request another reference'
      expect(href(result)).to eq '/candidate/application/references/start'
      expect(body_text(result)).to eq expected_first_para
    end
  end

  context 'and minimum required references have been provided' do
    it 'renders the correct content' do
      create(:reference, :feedback_provided, application_form: application_form)
      create(:reference, :feedback_provided, application_form: application_form)

      result = render_inline(described_class.new(application_form))
      expect(link_text(result)).to eq 'Request another reference'
      expect(href(result)).to eq '/candidate/application/references/start'
      expect(body_text(result)).to eq 'You can add as many referees as you like but you can only submit 2 with your application.'
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

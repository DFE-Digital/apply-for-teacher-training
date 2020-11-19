require 'rails_helper'

RSpec.describe CandidateInterface::AddReferenceComponent do
  let(:application_form) { create(:application_form) }

  context 'when the candidate has no viable references' do
    it 'renders successfully' do
      create(:reference, :feedback_refused, application_form: application_form)

      result = render_inline(described_class.new(application_form))

      expect(heading(result)).to eq 'Add a referee'
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

      expect(heading(result)).to eq 'Add a second referee'
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

      expect(heading(result)).to eq 'Add another referee'
      expect(link_text(result)).to eq 'Add another referee'
      expect(href(result)).to eq '/candidate/application/references/start'
      expect(body_text(result)).to eq expected_first_para + expected_second_para
    end
  end

  context 'when enough references have been provided' do
    it 'does not render any content' do
      create(:reference, :feedback_provided, application_form: application_form)
      create(:reference, :feedback_provided, application_form: application_form)

      result = render_inline(described_class.new(application_form))

      expect(heading(result)).to be_empty
      expect(link(result)).to be_empty
      expect(body_text(result)).to be_empty
    end
  end

private

  def heading(result)
    result.css('h2').text.strip
  end

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

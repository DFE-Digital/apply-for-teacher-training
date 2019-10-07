require 'rails_helper'

RSpec.describe ViewHelper, type: :helper do
  describe '#govuk_link_to' do
    it 'returns an anchor tag with the govuk-link class' do
      anchor_tag = helper.govuk_link_to('Woof', 'https://localhost:0103/dog/woof')

      expect(anchor_tag).to eq('<a class="govuk-link" href="https://localhost:0103/dog/woof">Woof</a>')
    end

    it 'returns an anchor tag with the govuk-link class and target="_blank"' do
      anchor_tag = helper.govuk_link_to('Meow', 'https://localhost:0103/cat/meow', target: :_blank)

      expect(anchor_tag).to eq('<a target="_blank" class="govuk-link" href="https://localhost:0103/cat/meow">Meow</a>')
    end

    it 'returns an anchor tag with additional HTML options' do
      anchor_tag = helper.govuk_link_to('Baaa', 'https://localhost:0103/sheep/baaa', class: 'govuk-link--no-visited-state', target: :_blank)

      expect(anchor_tag).to eq('<a class="govuk-link govuk-link--no-visited-state" target="_blank" href="https://localhost:0103/sheep/baaa">Baaa</a>')
    end
  end

  describe '#govuk_back_link_to' do
    it 'returns an anchor tag with the govuk-back-link class' do
      anchor_tag = helper.govuk_back_link_to('https://localhost:0103/snek/ssss')

      expect(anchor_tag).to eq('<a class="govuk-back-link" href="https://localhost:0103/snek/ssss">Back</a>')
    end
  end

  describe '#bat_contact_mail_to' do
    it 'returns an anchor tag with href="mailto:" and the govuk-link class' do
      anchor_tag = helper.bat_contact_mail_to

      expect(anchor_tag).to eq('<a class="govuk-link" href="mailto:becomingateacher@digital.education.gov.uk">becomingateacher@digital.education.gov.uk</a>')
    end

    it 'returns an anchor tag with the name' do
      anchor_tag = helper.bat_contact_mail_to('Contact the Becoming a Teacher team')

      expect(anchor_tag).to eq('<a class="govuk-link" href="mailto:becomingateacher@digital.education.gov.uk">Contact the Becoming a Teacher team</a>')
    end

    it 'returns an anchor tag with additional HTML options' do
      anchor_tag = helper.bat_contact_mail_to(html_options: { subject: 'Support and guidance', class: 'govuk-link--no-visited-state' })

      expect(anchor_tag).to eq('<a class="govuk-link govuk-link--no-visited-state" href="mailto:becomingateacher@digital.education.gov.uk?subject=Support%20and%20guidance">becomingateacher@digital.education.gov.uk</a>')
    end
  end
end

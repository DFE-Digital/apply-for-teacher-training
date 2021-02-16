require 'rails_helper'

RSpec.describe NotificationMessageComponent do
  let(:component) { render_inline(described_class.new(notification_type, message_details)) }
  let(:notification_type) { :info }
  let(:message_details) { { message: message, secondary_message: secondary_message, message_link: link } }
  let(:message) { 'This is a notification message' }
  let(:secondary_message) { nil }
  let(:link) { nil }

  it 'renders the banner title' do
    selector = '.govuk-notification-banner__title'

    expect(component.css(selector).text.squish).to eql(I18n.t(notification_type, scope: :notification_banner))
  end

  context 'heading' do
    it 'renders the message' do
      selector = '.govuk-notification-banner__content .govuk-notification-banner__heading'

      expect(component.css(selector).text.squish).to eql(message_details[:message])
    end

    context 'when the message has an inline link' do
      let(:message) { "Your application has been withdrawn. <a href='/apply-again'>Do you want to apply again?</a>" }

      it 'renders the message and any html added to it', wip: true do
        component_css = component.css('.govuk-notification-banner__content .govuk-notification-banner__heading a')

        expect(component_css.text).to eql('Do you want to apply again?')
        expect(component_css[0].attr('href')).to eql('/apply-again')
      end
    end
  end

  context 'message' do
    context 'when a secondary_message is present' do
      let(:secondary_message) { 'Another message' }

      it 'renders the secondary_message' do
        selector = '.govuk-notification-banner__content .govuk-body'

        expect(component.css(selector).text.squish).to eql(secondary_message)
      end
    end

    context 'when the secondary_message has an inline link' do
      let(:secondary_message) { "Another message <a hef='/apply-path'>Apply</a>" }

      it 'renders the message and any html added to it' do
        selector = '.govuk-notification-banner__content .govuk-body a'

        expect(component.css(selector).text).to eql('Apply')
      end
    end

    context 'when a link is present' do
      let(:link) { { text: 'Go to the previous page', url: 'http://example.link' }.with_indifferent_access }

      it 'renders the link' do
        component_css = component.css('.govuk-notification-banner__content .govuk-body a')

        expect(component_css.text.squish).to eql(link[:text])
        expect(component_css[0].attr('href')).to eql(link[:url])
      end
    end

    context 'when both a secondary_message and a link are present' do
      let(:secondary_message) { 'Another message' }
      let(:link) { { text: 'Go to the previous page', url: 'http://example.link' }.with_indifferent_access }

      it 'renders both the secondary_message and link' do
        selector = '.govuk-notification-banner__content .govuk-body'

        expect(component.css(selector).first.text.squish).to eql(secondary_message)
        expect(component.css(selector).last.text.squish).to eql(link[:text])
      end
    end

    context 'when neither a secondary_messager nor a link are present' do
      let(:secondary_message) { nil }
      let(:link) { nil }

      it 'only renders the secondary_message' do
        selector = '.govuk-notification-banner__content .govuk-body'

        expect(component.css(selector)).to be_empty
      end
    end
  end

  context 'role' do
    let(:selector) { '.govuk-notification-banner' }

    context 'when the notification_type is success or warning' do
      let(:notification_type) { %i[success warning].sample }

      it 'returns alert' do
        expect(component.css(selector).attr('role').value).to eql('alert')
      end
    end

    context 'when the notification_type is info' do
      let(:notification_type) { :info }

      it 'returns region' do
        expect(component.css(selector).attr('role').value).to eql('region')
      end
    end
  end
end

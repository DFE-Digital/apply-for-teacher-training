require 'rails_helper'

RSpec.describe HeaderComponent do
  let(:navigation_items) { [] }
  let(:homepage_url) { nil }

  subject(:rendered_component) do
    render_inline(described_class.new(navigation_items: navigation_items, homepage_url: homepage_url, service_name: '', service_link: '#'))
  end

  describe 'rendering the homepage_url' do
    let(:header_link_xpath) { './/a[@class="govuk-header__link govuk-header__link--homepage"]/@href' }

    context 'when no homepage_url is not set' do
      it 'defauls to the govuk website' do
        expect(rendered_component.xpath(header_link_xpath).first.value).to eq('https://www.gov.uk')
      end
    end

    context 'when no homepage_url is set' do
      let(:homepage_url) { '/provider' }

      it 'links to the specified url' do
        expect(rendered_component.xpath(header_link_xpath).first.value).to eq(homepage_url)
      end
    end
  end

  describe 'rendering NavigationItems' do
    context 'when they are links' do
      let(:navigation_items) do
        [
          NavigationItems::NavigationItem.new(
            'I am a link',
            'http://my.url',
            false,
          ),
        ]
      end

      it 'renders them correctly' do
        expect(rendered_component.text).to include 'I am a link'
        expect(rendered_component.xpath(".//li/a[@href='http://my.url']")).to be_present
      end
    end

    context 'when they are not links' do
      let(:navigation_items) do
        [
          NavigationItems::NavigationItem.new(
            'I am not a link',
            nil,
            false,
          ),
        ]
      end

      it 'does not try to render them as links' do
        expect(rendered_component.xpath('.//li/a')).not_to be_present
      end
    end

    context 'when they are active' do
      let(:navigation_items) do
        [
          NavigationItems::NavigationItem.new(
            'I am not a link',
            nil,
            true,
            [],
          ),
        ]
      end

      it 'assigns the --active class' do
        expect(rendered_component.to_s).to include 'govuk-header__navigation-item--active'
      end
    end
  end
end

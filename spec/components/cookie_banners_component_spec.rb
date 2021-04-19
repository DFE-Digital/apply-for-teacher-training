require 'rails_helper'

RSpec.describe CookieBannersComponent, type: :component do
  describe '#render' do
    %w[candidate_interface provider_interface].each do |namespace|
      it "renders when current namespace is #{namespace}" do
        component = described_class.new(current_namespace: 'candidate_interface', request_path: '/')
        result = render_inline(component)

        expect(result.to_html).not_to be_blank
      end
    end

    it 'does not render when current namespace is invalid' do
      component = described_class.new(current_namespace: 'support_interface', request_path: '/')
      result = render_inline(component)

      expect(result.to_html).to be_blank
    end

    it "does not render with invalid 'current_page'" do
      component = described_class.new(current_namespace: 'candidate_interface', request_path: url_helpers.candidate_interface_cookies_path)
      result = render_inline(component)

      expect(result.to_html).to be_blank
    end
  end

  describe '#service_name_short' do
    context 'candidate_interface' do
      it "returns 'apply'" do
        component = described_class.new(current_namespace: 'candidate_interface', request_path: url_helpers.candidate_interface_cookies_path)

        expect(component.service_name_short).to eq('apply')
      end
    end

    context 'provider_interface' do
      it "returns 'manage'" do
        component = described_class.new(current_namespace: 'provider_interface', request_path: url_helpers.provider_interface_cookies_path)

        expect(component.service_name_short).to eq('manage')
      end
    end
  end

  describe '#namespace_cookies_path' do
    context 'candidate_interface' do
      it 'returns candidate_interface_cookies_path' do
        component = described_class.new(current_namespace: 'candidate_interface', request_path: '/')

        expect(component.namespace_cookies_path).to eq(url_helpers.candidate_interface_cookies_path)
      end
    end

    context 'provider_interface' do
      it 'returns provider_interface_cookies_path' do
        component = described_class.new(current_namespace: 'provider_interface', request_path: '/')

        expect(component.namespace_cookies_path).to eq(url_helpers.provider_interface_cookies_path)
      end
    end
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::ContentController do
  describe 'visit /provider/service-guidance' do
    it 'returns 200' do
      get provider_interface_service_guidance_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'visit /provider/service-guidance/dates-and-deadlines' do
    it 'returns 200' do
      get provider_interface_service_guidance_dates_and_deadlines_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'visit /provider/privacy' do
    it 'returns 200' do
      get provider_interface_privacy_path

      expect(response).to have_http_status :ok
    end
  end

  describe 'visit /provider/privacy/online-chat-privacy-notice' do
    it 'returns 200' do
      get provider_interface_online_chat_privacy_notice_path

      expect(response).to have_http_status :ok
    end
  end
end

require 'rails_helper'

RSpec.describe SupportInterface::ProviderSyncCoursesToggleComponent do
  context 'when Provider#sync_courses is switched off' do
    before do
      @provider = create :provider
      @rendered_component = render_inline(
        SupportInterface::ProviderSyncCoursesToggleComponent, provider: @provider
      )
    end

    it 'renders correct status label' do
      expect(@rendered_component.text).to include('Course synching for this provider is switched off')
    end

    it 'renders correct toggle button' do
      expect(@rendered_component.css('input.govuk-button')[0].attr('value')).to include('Enable course syncing from Find')
      expect(@rendered_component.css('form')[0].attr('action')).to eq(
        Rails.application.routes.url_helpers.support_interface_enable_provider_course_syncing_path(@provider),
      )
    end
  end

  context 'when Provider#sync_courses is switched on' do
    before do
      @provider = create :provider, sync_courses: true
      @rendered_component = render_inline(
        SupportInterface::ProviderSyncCoursesToggleComponent, provider: @provider
      )
    end

    it 'renders correct status label' do
      expect(@rendered_component.text).to include('Course synching for this provider is switched on')
    end

    it 'does not render a toggle button' do
      expect(@rendered_component.css('input.govuk-button')).to be_blank
    end
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationTimelineComponent do
  context 'for a newly created application' do
    it 'renders empty timeline' do
      application_choice = instance_double(ApplicationChoice)

      rendered = render_inline(described_class.new(application_choice: application_choice))
      expect(rendered.text).to include 'Timeline'
    end
  end
end

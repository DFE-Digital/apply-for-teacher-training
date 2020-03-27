require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationCardComponent do
  include CourseOptionHelpers

  describe 'rendering' do
    it 'renders what it should' do
      current_provider = create(:provider,
                                :with_signed_agreement,
                                code: 'ABC',
                                name: 'Hoth Teacher Training')

      course_option = course_option_for_provider(provider: current_provider,
                                                     course: create(:course,
                                                                    name: 'Alchemy',
                                                                    provider: current_provider,
                                                                    accrediting_provider: current_provider))

      application_choice = create(:application_choice,
                                  :awaiting_provider_decision,
                                  course_option: course_option,
                                  status: 'withdrawn', application_form: create(:application_form,
                                                                                first_name: 'Jim',
                                                                                last_name: 'James'),
                                                                                updated_at: Date.parse('25-03-2020'))

      result = render_inline described_class.new(application_choice: application_choice, index: 1)

      card = result.css('[data-qa=application-card-1]')
      card_primary = card.css('> div.app-application-card__primary')
      card_secondary = card.css('> div.app-application-card__secondary')

      expect(card_primary.css('> h3').text).to include('Jim James')
      expect(card_primary.css('> p:nth-of-type(1)').text).to include('Hoth Teacher Training')
      expect(card_primary.css('> p:nth-of-type(2)').text).to include('Alchemy')
      expect(card_primary.css('> p:nth-of-type(3)').text).to include('Hoth Teacher Training')
      expect(card_secondary.css('> div').text).to include('Application withdrawn')
      expect(card_secondary.css('> p').text).to include('25 Mar 2020')
    end
  end
end

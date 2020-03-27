require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationCardComponent do
  include CourseOptionHelpers

  let(:current_provider) do
    create(:provider,
           :with_signed_agreement,
           code: 'ABC',
           name: 'Hoth Teacher Training')
  end

  let(:course_option) do
    course_option_for_provider(provider: current_provider,
                               course: create(:course,
                                              name: 'Alchemy',
                                              provider: current_provider,
                                              accrediting_provider: current_provider))
  end

  let(:application_choice) do
    create(:application_choice,
           :awaiting_provider_decision,
           course_option: course_option,
           status: 'withdrawn', application_form: create(:application_form,
                                                         first_name: 'Jim',
                                                         last_name: 'James'),
                                                         updated_at: Date.parse('25-03-2020'))
  end

  let(:result) { render_inline described_class.new(application_choice: application_choice, index: 1) }

  let(:card) { result.css('[data-qa=application-card-1]') }

  let(:card_primary) { card.css('> div.app-application-card__primary') }

  let(:card_secondary) { card.css('> div.app-application-card__secondary') }

  describe 'rendering' do
    it 'renders the name of the candidate' do
      expect(card_primary.css('> h3').text).to include('Jim James')
    end

    it 'renders the name of education provider' do
      expect(card_primary.css('> p:nth-of-type(1)').text).to include('Hoth Teacher Training')
    end

    it 'renders the name of the course' do
      expect(card_primary.css('> p:nth-of-type(2)').text).to include('Alchemy')
    end

    it 'renders the name of the accredited provider' do
      expect(card_primary.css('> p:nth-of-type(3)').text).to include('Hoth Teacher Training')
    end

    it 'renders the status of the application' do
      expect(card_secondary.css('> div').text).to include('Application withdrawn')
    end

    it 'renders the last updated date' do
      expect(card_secondary.css('> p').text).to include('25 Mar 2020')
    end
  end
end

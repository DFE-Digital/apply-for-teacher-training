require 'rails_helper'

RSpec.describe ProviderInterface::ApplicationCardComponent do
  include CourseOptionHelpers

  let(:current_provider) do
    create(:provider,
           :with_signed_agreement,
           code: 'ABC',
           name: 'Hoth Teacher Training')
  end

  let(:accredited_provider) do
    create(:provider,
           :with_signed_agreement,
           code: 'XYZ',
           name: 'Yavin University')
  end

  let(:course_option) do
    course_option_for_provider(provider: current_provider,
                               course: create(:course,
                                              name: 'Alchemy',
                                              provider: current_provider,
                                              accredited_provider: accredited_provider))
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

  let(:note) do
    provider_user = current_provider.provider_users.first
    Note.new(
      provider_user: provider_user,
      subject: 'Needs review',
      message: 'Please review asap as the deadline is looming.',
    )
  end

  let(:result) { render_inline described_class.new(application_choice: application_choice) }

  let(:card) { result.css('.app-application-card').to_html }

  describe 'rendering' do
    it 'renders the name of the candidate' do
      expect(card).to include('Jim James')
    end

    it 'renders the name of education provider' do
      expect(card).to include('Hoth Teacher Training')
    end

    it 'renders the name of the course' do
      expect(card).to include('Alchemy')
    end

    it 'renders the name of the accredited provider' do
      expect(card).to include('Yavin University')
    end

    it 'renders the status of the application' do
      expect(card).to include('Application withdrawn')
    end

    it 'renders the subject of the most recent note' do
      FeatureFlag.activate('notes')
      application_choice.notes << note
      expect(card).to include(note.subject)
    end

    it 'renders the last updated date' do
      expect(card).to include('25 Mar 2020')
    end

    context 'when there is no accredited provider' do
      let(:course_option_without_accredited_provider) do
        course_option_for_provider(provider: current_provider,
                                   course: create(:course,
                                                  name: 'Baking',
                                                  provider: current_provider))
      end

      let(:application_choice_without_accredited_provider) do
        create(:application_choice,
               :awaiting_provider_decision,
               course_option: course_option_without_accredited_provider,
               status: 'withdrawn', application_form: create(:application_form,
                                                             first_name: 'Jim',
                                                             last_name: 'James'),
               updated_at: Date.parse('25-03-2020'))
      end

      let(:result) { render_inline described_class.new(application_choice: application_choice_without_accredited_provider) }

      it 'renders the course provider name instead' do
        expect(result.css('.app-application-card__secondary').text).to include('Hoth Teacher Training')
      end
    end
  end
end

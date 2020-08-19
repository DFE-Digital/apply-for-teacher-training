require 'rails_helper'

RSpec.describe ProviderInterface::DiversityInformationComponent do
  let(:training_provider) { create(:provider) }
  let(:ratifying_provider) { create(:provider) }
  let(:course) { create(:course, provider: training_provider, accredited_provider: ratifying_provider) }
  let(:provider_relationship_permissions) do
    create(
      :provider_relationship_permissions,
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
      training_provider_can_view_diversity_information: true,
    )
  end
  let(:provider_user) { create(:provider_user, providers: [training_provider]) }
  let(:diversity_info) do
    { 'sex' => 'male',
      'disabilities' => ['Mental health condition', 'Social or communication impairment', 'Acquired brain injury'],
      'ethnic_group' => 'Asian or Asian British',
      'ethnic_background' => 'Chinese' }
  end

  context 'when the candidate has not shared diversity information' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        equality_and_diversity: nil,
      )
      application_choice = build(:application_choice,
                                 application_form: application_form,
                                 course: course)
      result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

      expect(result.text).to include('No information shared')
      expect(result.text).not_to include('This will become available to users with permissions to `view diversity information` when an offer has been accepted')
      expect(result.text).not_to include('This section is only available to users with permissions to `view diversity information`.')
      expect(result.text).not_to include('You will be able to view this when an offer has been accepted.')
    end
  end

  context 'when the candidate has shared diversity information' do
    let(:application_form) do
      build_stubbed(
        :application_form,
        equality_and_diversity: diversity_info,
      )
    end

    context 'when the application is accepted' do
      let!(:application_choice) do
        build(:application_choice,
              application_form: application_form,
              course: course,
              status: 'pending_conditions')
      end

      context 'when provider user does not have permissions to view diversity information and the application is accepted' do
        it 'displays the correct text' do
          provider_user.provider_permissions.find_by(provider: training_provider)
            .update!(view_diversity_information: false)
          result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

          expect(result.text).to include('The candidate disclosed information in the equality and diversity questionnaire.')
          expect(result.text).to include('This section is only available to users with permissions to `view diversity information`.')
        end
      end

      context 'when training provider organisation does not have permissions to view diversity information and the application is accepted' do
        it 'displays the correct text' do
          provider_relationship_permissions.update!(
            training_provider_can_view_diversity_information: false,
            ratifying_provider_can_view_diversity_information: true,
          )
          result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

          expect(result.text).to include('The candidate disclosed information in the equality and diversity questionnaire.')
          expect(result.text).to include('This section is only available to users with permissions to `view diversity information`.')
        end
      end
    end

    context 'when the application is awaiting provider decision' do
      let!(:application_choice) do
        build(:application_choice,
              application_form: application_form,
              course: course,
              status: 'awaiting_provider_decision')
      end

      context 'when provider user can view diversity information' do
        it 'displays the correct text' do
          provider_relationship_permissions
          provider_user.provider_permissions.find_by(provider: training_provider)
            .update!(view_diversity_information: true)
          result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

          expect(result.text).to include('The candidate disclosed information in the equality and diversity questionnaire.')
          expect(result.text).to include('You will be able to view this when an offer has been accepted.')
        end
      end

      context 'when provider user does not have permissions to view diversity information' do
        it 'displays the correct text' do
          provider_user.provider_permissions.find_by(provider: training_provider)
            .update!(view_diversity_information: false)
          result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

          expect(result.text).to include('The candidate disclosed information in the equality and diversity questionnaire.')
          expect(result.text).to include('This will become available to users with permissions to `view diversity information` when an offer has been accepted')
        end
      end

      context 'when training provider organisation does not have permissions to view diversity information' do
        it 'displays the correct text' do
          provider_relationship_permissions.update!(
            training_provider_can_view_diversity_information: false,
            ratifying_provider_can_view_diversity_information: true,
          )

          result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

          expect(result.text).to include('The candidate disclosed information in the equality and diversity questionnaire.')
          expect(result.text).to include('This will become available to users with permissions to `view diversity information` when an offer has been accepted')
        end
      end
    end
  end
end

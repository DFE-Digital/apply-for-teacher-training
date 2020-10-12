require 'rails_helper'

RSpec.describe ProviderInterface::SafeguardingDeclarationComponent do
  let(:training_provider) { create(:provider) }
  let(:ratifying_provider) { create(:provider) }
  let(:course) { create(:course, provider: training_provider, accredited_provider: ratifying_provider) }
  let(:provider_relationship_permissions) do
    create(
      :provider_relationship_permissions,
      training_provider: training_provider,
      ratifying_provider: ratifying_provider,
      training_provider_can_view_safeguarding_information: true,
    )
  end
  let(:provider_user) { create(:provider_user, providers: [training_provider]) }

  context 'when the candidate was never asked the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'never_asked',
      )
      application_choice = build(:application_choice,
                                 application_form: application_form,
                                 course: course)
      result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

      expect(result.text).to include('Never asked.')
    end
  end

  context 'when the candidate has shared information related to safeguarding' do
    let(:application_form) do
      build_stubbed(:application_form,
                    safeguarding_issues: 'I have a criminal conviction.',
                    safeguarding_issues_status: 'has_safeguarding_issues_to_declare')
    end

    let(:application_choice) do
      build(:application_choice,
            application_form: application_form,
            course: course)
    end

    context 'when provider user can view safeguarding information' do
      it 'displays the correct text' do
        provider_relationship_permissions

        provider_user.provider_permissions.find_by(provider: training_provider)
          .update!(view_safeguarding_information: true)
        result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

        expect(result.text).to include(t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare'))
        expect(result.css('.govuk-details__summary-text').text).to include('View information disclosed by the candidate')
        expect(result.css('.govuk-details__text').text).to include('I have a criminal conviction.')
      end
    end

    context 'when provider user does not have permissions to view safeguarding information' do
      it 'displays the correct text' do
        provider_user.provider_permissions.find_by(provider: training_provider)
          .update!(view_safeguarding_information: false)
        result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

        expect(result.text).to include(t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare_no_permissions'))
        expect(result.text).not_to include('View information disclosed by the candidate')
      end
    end

    context 'when training provider organisation does not have permissions to view safeguarding information' do
      before do
        provider_relationship_permissions.update!(
          training_provider_can_view_safeguarding_information: false,
          ratifying_provider_can_view_safeguarding_information: true,
        )

        provider_user.provider_permissions.find_by(provider: training_provider).update(view_safeguarding_information: true)
      end

      it 'when user has manage_organisations' do
        provider_user.provider_permissions.find_by(provider: training_provider).update(manage_organisations: true)
        result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

        expect(result.text).to include(t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare_no_permissions'))
        expect(result.text).not_to include('View information disclosed by the candidate')
        expect(result.text).to include('allow yourself access to this information')
      end

      it 'when user does not have manage_organisations' do
        provider_user.provider_permissions.find_by(provider: training_provider).update(manage_organisations: false)
        provider_user_who_can_fix = create(
          :provider_permissions,
          provider: training_provider,
          manage_organisations: true,
        ).provider_user

        result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

        expect(result.text).to include(t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare_no_permissions'))
        expect(result.text).not_to include('View information disclosed by the candidate')
        expect(result.text).to include(provider_user_who_can_fix.email_address)
      end
    end

    context 'when ratifying provider organisation does not have permissions to view safeguarding information' do
      let(:provider_user) { create(:provider_user, providers: [ratifying_provider]) }

      before do
        provider_relationship_permissions.update!(
          training_provider_can_view_safeguarding_information: false,
          ratifying_provider_can_view_safeguarding_information: true,
        )
      end

      it 'displays the correct text' do
        result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

        expect(result.text).to include(t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare_no_permissions'))
        expect(result.text).not_to include('View information disclosed by the candidate')
      end

      it 'suggests contacting the training provider to fix' do
        result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))
        expect(result.text).to include(training_provider.name)
      end
    end
  end

  context 'when the candidate has not shared information related to safeguarding' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'no_safeguarding_issues_to_declare',
      )
      application_choice = build(:application_choice,
                                 application_form: application_form,
                                 course: course)
      result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

      expect(result.text).to include('No information shared.')
      expect(result.text).not_to include('View information disclosed by the candidate')
    end
  end

  context 'when the candidate has not answered the safeguarding question' do
    it 'displays the correct text' do
      application_form = build_stubbed(
        :application_form,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'not_answered_yet',
      )
      application_choice = build(:application_choice,
                                 application_form: application_form,
                                 course: course)
      result = render_inline(described_class.new(application_choice: application_choice, current_provider_user: provider_user))

      expect(result.text).to include('Not answered yet')
      expect(result.text).not_to include('View information disclosed by the candidate')
    end
  end
end

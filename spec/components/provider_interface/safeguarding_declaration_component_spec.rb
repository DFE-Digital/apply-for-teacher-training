require 'rails_helper'

RSpec.describe ProviderInterface::SafeguardingDeclarationComponent do
  let(:training_provider) { create(:provider) }
  let(:ratifying_provider) { create(:provider) }
  let(:course) { create(:course, provider: training_provider, accredited_provider: ratifying_provider) }
  let(:course_option) { create(:course_option, course:) }

  def one_sided_permissions(side_with_access:, setup_at: nil)
    @relationship = if side_with_access == :ratifying_provider
                      create(
                        :provider_relationship_permissions,
                        training_provider:,
                        ratifying_provider:,
                        training_provider_can_make_decisions: false,
                        training_provider_can_view_safeguarding_information: false,
                        training_provider_can_view_diversity_information: false,
                        ratifying_provider_can_make_decisions: true,
                        ratifying_provider_can_view_safeguarding_information: true,
                        ratifying_provider_can_view_diversity_information: true,
                        setup_at:,
                      )
                    else
                      create(
                        :provider_relationship_permissions,
                        training_provider:,
                        ratifying_provider:,
                        training_provider_can_make_decisions: true,
                        training_provider_can_view_safeguarding_information: true,
                        training_provider_can_view_diversity_information: true,
                        ratifying_provider_can_make_decisions: false,
                        ratifying_provider_can_view_safeguarding_information: false,
                        ratifying_provider_can_view_diversity_information: false,
                        setup_at:,
                      )
                    end
  end

  def user_has_view_safeguarding_information(status)
    provider_user.provider_permissions.update_all(view_safeguarding_information: status)
  end

  def user_has_manage_users(status)
    provider_user.provider_permissions.update_all(manage_users: status)
  end

  def user_has_manage_organisations(status)
    provider_user.provider_permissions.update_all(manage_organisations: status)
  end

  def render_component(user:, safeguarding_issues:, safeguarding_issues_status:, previous_training_status: 'no')
    application_form = create(
      :application_form,
      safeguarding_issues:,
      safeguarding_issues_status:,
    )

    if previous_training_status == 'no'
      create(:previous_teacher_training, :not_started, :published, application_form:)
    end

    if previous_training_status == 'yes'
      create(:previous_teacher_training, :published, application_form:)
    end

    application_choice = create(
      :application_choice,
      application_form:,
      course_option:,
    )
    render_inline(described_class.new(application_choice:, current_provider_user: user))
  end

  def expect_user_can_see_safeguarding_information(result)
    expect(result.text).to include(
      "#{t('provider_interface.safeguarding_declaration_component.declare_safeguarding_issues')}#{t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare')}",
    )
    expect(result.text).to include('I have a criminal conviction.')
    expect(result.text).not_to include(I18n.t('provider_interface.safeguarding_declaration_component.cannot_see_safeguarding_information'))
  end

  def expect_user_cannot_see_safeguarding_information(result)
    expect(result.text).to include(I18n.t('provider_interface.safeguarding_declaration_component.cannot_see_safeguarding_information'))
  end

  context 'provider relationship allows training_provider access to safeguarding information' do
    let(:provider_user) { create(:provider_user, providers: [training_provider]) }

    before do
      one_sided_permissions(side_with_access: :training_provider, setup_at: Time.zone.now)
    end

    context 'when the candidate was never asked the safeguarding question' do
      it 'does not show the safeguarding section' do
        result = render_component(
          user: provider_user,
          safeguarding_issues: nil,
          safeguarding_issues_status: 'never_asked',
        )
        expect(result.text).to include('Safeguarding')
        expect(result.text).to include('No')
      end
    end

    it 'when the candidate has declared no safeguarding issues' do
      result = render_component(
        user: provider_user,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'no_safeguarding_issues_to_declare',
      )
      expect(result.text).not_to include(I18n.t('provider_interface.safeguarding_declaration_component.safeguarding_information'))
    end

    it 'when the candidate has shared information related to safeguarding' do
      user_has_view_safeguarding_information(true)
      result = render_component(
        user: provider_user,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
      )
      expect_user_can_see_safeguarding_information(result)

      user_has_view_safeguarding_information(false)
      result = render_component(
        user: provider_user,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
      )
      expect_user_cannot_see_safeguarding_information(result)
    end
  end

  context 'provider relationship allows ratifying_provider access to safeguarding information' do
    let(:provider_user) { create(:provider_user, providers: [ratifying_provider]) }

    before do
      one_sided_permissions(side_with_access: :ratifying_provider, setup_at: Time.zone.now)
    end

    context 'when the candidate was never asked the safeguarding question' do
      it 'does not display safeguarding section' do
        result = render_component(
          user: provider_user,
          safeguarding_issues: nil,
          safeguarding_issues_status: 'never_asked',
        )
        expect(result).not_to include('Criminal record and professional misconduct')
        expect(result).not_to include('Never asked')
        expect(result).not_to include(I18n.t('provider_interface.safeguarding_declaration_component.declare_safeguarding_issues'))
      end
    end

    context 'when the candidate has declared no safeguarding issues' do
      it 'display the first question only' do
        result = render_component(
          user: provider_user,
          safeguarding_issues: nil,
          safeguarding_issues_status: 'no_safeguarding_issues_to_declare',
        )
        expect(result.text).to include(
          "#{I18n.t('provider_interface.safeguarding_declaration_component.declare_safeguarding_issues')}#{I18n.t('provider_interface.safeguarding_declaration_component.no_safeguarding_issues_to_declare')}",
        )
      end
    end

    it 'when the candidate has shared information related to safeguarding' do
      user_has_view_safeguarding_information(true)
      result = render_component(
        user: provider_user,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
      )
      expect_user_can_see_safeguarding_information(result)

      user_has_view_safeguarding_information(false)
      result = render_component(
        user: provider_user,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
      )
      expect_user_cannot_see_safeguarding_information(result)
    end
  end

  context 'provider relationship forbids training_provider access to safeguarding information' do
    let(:provider_user) { create(:provider_user, providers: [training_provider]) }

    context 'when relationship permissions have not been set up' do
      before do
        one_sided_permissions(side_with_access: :ratifying_provider, setup_at: nil)

        user_has_view_safeguarding_information(true)
      end

      it 'shows no permission message' do
        user_has_manage_organisations(false)
        result = render_component(
          user: provider_user,
          safeguarding_issues: 'I have a criminal conviction.',
          safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        )
        expect_user_cannot_see_safeguarding_information(result)
      end
    end

    context 'when relationship permissions have already been setup' do
      before do
        one_sided_permissions(side_with_access: :ratifying_provider, setup_at: Time.zone.now)

        user_has_view_safeguarding_information(true)
      end

      it 'when provider user has manage_organisations' do
        user_has_manage_organisations(true)
        result = render_component(
          user: provider_user,
          safeguarding_issues: 'I have a criminal conviction.',
          safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        )
        expect_user_cannot_see_safeguarding_information(result)
      end

      it 'shows no permission message' do
        user_has_manage_organisations(false)
        result = render_component(
          user: provider_user,
          safeguarding_issues: 'I have a criminal conviction.',
          safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        )
        expect_user_cannot_see_safeguarding_information(result)
      end
    end
  end

  context 'provider relationship forbids ratifying_provider access to safeguarding information' do
    let(:provider_user) { create(:provider_user, providers: [ratifying_provider]) }

    before do
      one_sided_permissions(side_with_access: :training_provider, setup_at: nil)

      user_has_view_safeguarding_information(true)
      user_has_manage_organisations(true)
    end

    it 'shows no permission message' do
      result = render_component(
        user: provider_user,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
      )
      expect_user_cannot_see_safeguarding_information(result)
    end
  end
end

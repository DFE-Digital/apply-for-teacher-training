require 'rails_helper'

RSpec.describe ProviderInterface::SafeguardingDeclarationComponent do
  let(:training_provider) { create(:provider) }
  let(:ratifying_provider) { create(:provider) }
  let(:course) { create(:course, provider: training_provider, accredited_provider: ratifying_provider) }
  let(:course_option) { create(:course_option, course: course) }

  def one_sided_permissions(side_with_access:, setup_at: nil)
    @relationship = if side_with_access == :ratifying_provider
                      create(
                        :provider_relationship_permissions,
                        training_provider: training_provider,
                        ratifying_provider: ratifying_provider,
                        training_provider_can_make_decisions: false,
                        training_provider_can_view_safeguarding_information: false,
                        training_provider_can_view_diversity_information: false,
                        ratifying_provider_can_make_decisions: true,
                        ratifying_provider_can_view_safeguarding_information: true,
                        ratifying_provider_can_view_diversity_information: true,
                        setup_at: setup_at,
                      )
                    else
                      create(
                        :provider_relationship_permissions,
                        training_provider: training_provider,
                        ratifying_provider: ratifying_provider,
                        training_provider_can_make_decisions: true,
                        training_provider_can_view_safeguarding_information: true,
                        training_provider_can_view_diversity_information: true,
                        ratifying_provider_can_make_decisions: false,
                        ratifying_provider_can_view_safeguarding_information: false,
                        ratifying_provider_can_view_diversity_information: false,
                        setup_at: setup_at,
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

  def render_component(user:, safeguarding_issues:, safeguarding_issues_status:)
    application_form = create(
      :application_form,
      safeguarding_issues: safeguarding_issues,
      safeguarding_issues_status: safeguarding_issues_status,
    )
    application_choice = create(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
    )
    render_inline(described_class.new(application_choice: application_choice, current_provider_user: user))
  end

  def expect_user_can_see_safeguarding_information(result)
    expect(result.text).to include(t('provider_interface.safeguarding_declaration_component.has_safeguarding_issues_to_declare'))
    expect(result.css('.govuk-details__summary-text').text).to include('View information disclosed by the candidate')
    expect(result.css('.govuk-details__text').text).to include('I have a criminal conviction.')
  end

  def expect_user_cannot_see_safeguarding_information(result)
    expect(result.text).not_to include('View information disclosed by the candidate')
  end

  context 'provider relationship allows training_provider access to safeguarding information' do
    let(:provider_user) { create(:provider_user, providers: [training_provider]) }

    before do
      one_sided_permissions(side_with_access: :training_provider, setup_at: Time.zone.now)
    end

    it 'when the candidate was never asked the safeguarding question' do
      result = render_component(
        user: provider_user,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'never_asked',
      )
      expect(result.text).to include('Never asked.')
    end

    it 'when the candidate has declared no safeguarding issues' do
      result = render_component(
        user: provider_user,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'no_safeguarding_issues_to_declare',
      )
      expect(result.text).to include('The candidate has declared no criminal convictions or other safeguarding issues.')
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

    it 'when the candidate was never asked the safeguarding question' do
      result = render_component(
        user: provider_user,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'never_asked',
      )
      expect(result.text).to include('Never asked.')
    end

    it 'when the candidate has declared no safeguarding issues' do
      result = render_component(
        user: provider_user,
        safeguarding_issues: nil,
        safeguarding_issues_status: 'no_safeguarding_issues_to_declare',
      )
      expect(result.text).to include('The candidate has declared no criminal convictions or other safeguarding issues.')
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

      it 'when provider user has manage_organisations' do
        user_has_manage_organisations(true)
        result = render_component(
          user: provider_user,
          safeguarding_issues: 'I have a criminal conviction.',
          safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        )
        expect_user_cannot_see_safeguarding_information(result)
        fix_it_link = Rails.application.routes.url_helpers.provider_interface_edit_provider_relationship_permissions_path(id: @relationship.id)
        expect(result.to_html).to include(fix_it_link)
      end

      it 'when provider user does not have manage_organisations' do
        user_has_manage_organisations(false)
        result = render_component(
          user: provider_user,
          safeguarding_issues: 'I have a criminal conviction.',
          safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        )
        expect_user_cannot_see_safeguarding_information(result)
        expect(result.text).to include('Contact support at becomingateacher@digital.education.gov.uk')

        admin1 = create(:provider_user, providers: [training_provider])
        admin1.provider_permissions.update_all(manage_organisations: true)
        result = render_component(
          user: provider_user,
          safeguarding_issues: 'I have a criminal conviction.',
          safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        )
        expect(result.text).to include(admin1.email_address)

        admin2 = create(:provider_user, providers: [training_provider])
        admin2.provider_permissions.update_all(manage_organisations: true)
        result = render_component(
          user: provider_user,
          safeguarding_issues: 'I have a criminal conviction.',
          safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        )
        expect(result.text).to include(admin2.email_address)
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

      it 'when provider user does not have manage_organisations' do
        user_has_manage_organisations(false)
        result = render_component(
          user: provider_user,
          safeguarding_issues: 'I have a criminal conviction.',
          safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
        )
        expect_user_cannot_see_safeguarding_information(result)
        expect(result.text).to include("However, #{training_provider.name} does not have permission to see safeguarding information")
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

    it 'prompts ratifying provider user to contact support' do
      result = render_component(
        user: provider_user,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
      )
      expect_user_cannot_see_safeguarding_information(result)
      expect(result.text).to include('Contact support at becomingateacher@digital.education.gov.uk')
    end

    it 'prompts ratifying provider user to contact training provider admin' do
      training_provider_admin = create(:provider_user, providers: [training_provider])
      training_provider_admin.provider_permissions.update_all(manage_organisations: true)

      result = render_component(
        user: provider_user,
        safeguarding_issues: 'I have a criminal conviction.',
        safeguarding_issues_status: 'has_safeguarding_issues_to_declare',
      )
      expect_user_cannot_see_safeguarding_information(result)
      expect(result.text).to include(training_provider_admin.full_name)
      expect(result.text).to include(training_provider_admin.email_address)
    end
  end
end

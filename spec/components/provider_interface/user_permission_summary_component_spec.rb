require 'rails_helper'

RSpec.describe ProviderInterface::UserPermissionSummaryComponent, type: :controller do
  let(:current_provider_user) { create(:provider_user) }
  let(:provider_user) { create(:provider_user) }
  let(:provider) { create(:provider) }
  let!(:permissions) do
    FactoryBot.create(:provider_permissions,
                      provider: provider,
                      provider_user: provider_user,
                      manage_users: Faker::Boolean.boolean(true_ratio: 0.5),
                      manage_organisations: Faker::Boolean.boolean(true_ratio: 0.5),
                      set_up_interviews: Faker::Boolean.boolean(true_ratio: 0.5),
                      make_decisions: Faker::Boolean.boolean(true_ratio: 0.5),
                      view_safeguarding_information: Faker::Boolean.boolean(true_ratio: 0.5),
                      view_diversity_information: Faker::Boolean.boolean(true_ratio: 0.5))
  end

  let(:allowed_providers) { create_list(:provider, 3) }
  let(:prohibited_providers) { create_list(:provider, 2) }
  let(:render) do
    render_inline(described_class.new(provider_user: provider_user,
                                      provider: provider,
                                      current_user: current_provider_user))
  end

  before do
    allowed_providers.each do |training_provider|
      FactoryBot.create(:provider_relationship_permissions,
                        training_provider: training_provider,
                        ratifying_provider: provider,
                        training_provider_can_make_decisions: true,
                        training_provider_can_view_safeguarding_information: true,
                        training_provider_can_view_diversity_information: true)
    end

    prohibited_providers.each do |training_provider|
      FactoryBot.create(:provider_relationship_permissions,
                        training_provider: training_provider,
                        ratifying_provider: provider,
                        training_provider_can_make_decisions: false,
                        training_provider_can_view_safeguarding_information: false,
                        training_provider_can_view_diversity_information: false,
                        setup_at: nil)
    end
  end

  def row_text_selector(row_name, render)
    rows = {
      manage_users: 0,
      manage_permissions: 1,
      set_up_interviews: 2,
      make_decisions: 3,
      view_safeguarding_information: 4,
      view_diversity_information: 5,
    }

    render.css('.govuk-summary-list__row')[rows[row_name]].text
  end

  describe 'rendering details about each permission' do
    it 'displays the correct details for Managing users' do
      expect(row_text_selector(:manage_users, render)).to include('Manage users')
      expect(row_text_selector(:manage_users, render)).to include(y_n(permissions.manage_users))
    end

    it 'displays the correct details for Managing organisations' do
      expect(row_text_selector(:manage_permissions, render)).to include('Manage organisation permissions')
      expect(row_text_selector(:manage_permissions, render)).to include(y_n(permissions.manage_organisations))
    end

    it 'displays the correct details for Set up interviews' do
      expect(row_text_selector(:set_up_interviews, render)).to include('Set up interviews')
      expect(row_text_selector(:set_up_interviews, render)).to include(y_n(permissions.set_up_interviews))
    end

    it 'displays the correct details for Make decisions' do
      expect(row_text_selector(:make_decisions, render)).to include('Make offers and reject applications')
      expect(row_text_selector(:make_decisions, render)).to include(y_n(permissions.make_decisions))
    end

    it 'displays the correct details for Viewing safeguarding information' do
      expect(row_text_selector(:view_safeguarding_information, render)).to include('View criminal convictions and professional misconduct')
      expect(row_text_selector(:view_safeguarding_information, render)).to include(y_n(permissions.view_safeguarding_information))
    end

    it 'displays the correct details for Viewing diversity information' do
      expect(row_text_selector(:view_diversity_information, render)).to include('View sex, disability and ethnicity information')
      expect(row_text_selector(:view_diversity_information, render)).to include(y_n(permissions.view_diversity_information))
    end

    context 'when user level permissions are false' do
      before do
        permissions.update!(view_diversity_information: false)
      end

      it 'does not display organisation level permissions' do
        expect(row_text_selector(:view_diversity_information, render)).to include('View sex, disability and ethnicity information')
        expect(row_text_selector(:view_diversity_information, render)).to include('No')
        expect(row_text_selector(:view_diversity_information, render)).not_to include('This user permission is affected by organisation permissions.')
      end
    end

    context 'when user level permissions are true' do
      before do
        permissions.update!(view_diversity_information: true)
      end

      it 'displays organisation level permissions' do
        expect(row_text_selector(:view_diversity_information, render)).to include('View sex, disability and ethnicity information')
        expect(row_text_selector(:view_diversity_information, render)).to include('Yes')
        expect(row_text_selector(:view_diversity_information, render)).to include('This user permission is affected by organisation permissions.')
      end
    end

    context 'when the user can manage users permissions' do
      let!(:current_user_permissions) do
        FactoryBot.create(:provider_permissions,
                          provider: provider,
                          provider_user: current_provider_user,
                          manage_users: true)
      end

      it 'displays a change link' do
        expect(row_text_selector(:view_diversity_information, render)).to include('Change')
      end
    end

    context 'when the user cannot manage users permissions' do
      let!(:current_user_permissions) do
        FactoryBot.create(:provider_permissions,
                          provider: provider,
                          provider_user: current_provider_user,
                          manage_users: false)
      end

      it 'does not display a change link' do
        expect(row_text_selector(:view_diversity_information, render)).not_to include('Change')
      end
    end
  end

  def y_n(boolean)
    boolean ? 'Yes' : 'No'
  end
end

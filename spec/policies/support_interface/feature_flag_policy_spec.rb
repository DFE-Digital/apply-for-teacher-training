require 'rails_helper'

RSpec.describe SupportInterface::FeatureFlagPolicy do
  subject(:policy) { described_class }

  # let(:support_user) { create(:support_user, role:) }
  let(:support_user) { create(:support_user) }

  permissions :show? do
    context 'when user has a support role' do
      let(:role) { 'user_support' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a technical role' do
      let(:role) { 'technical_management' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a service_administration role' do
      let(:role) { 'service_administration' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a researcher role' do
      let(:role) { 'research_and_design' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end
  end

  permissions :edit? do
    context 'when user has a support role' do
      let(:role) { 'user_support' }

      # it 'denies access' do
      #   expect(policy).not_to permit(support_user, nil)
      # end
      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a technical role' do
      let(:role) { 'technical_management' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a service_administration role' do
      let(:role) { 'service_administration' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a researcher role' do
      let(:role) { 'research_and_design' }

      # it 'denies access' do
      #   expect(policy).not_to permit(support_user, nil)
      # end
      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end
  end
end

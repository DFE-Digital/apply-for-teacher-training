require 'rails_helper'

RSpec.describe SupportInterface::SupportUserPolicy do
  subject(:policy) { described_class }

  let(:support_user) { create(:support_user, role:) }

  permissions :show? do
    context 'when user has a support role' do
      let(:role) { 'support' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a technical role' do
      let(:role) { 'technical' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a business role' do
      let(:role) { 'business' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a researcher role' do
      let(:role) { 'researcher' }

      # it 'denies access' do
      #   expect(policy).not_to permit(support_user, nil)
      # end
      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end
  end

  permissions :edit? do
    context 'when user has a support role' do
      let(:role) { 'support' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a technical role' do
      let(:role) { 'technical' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a business role' do
      let(:role) { 'business' }

      # it 'denies access' do
      #   expect(policy).not_to permit(support_user, nil)
      # end
      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a researcher role' do
      let(:role) { 'researcher' }

      # it 'denies access' do
      #   expect(policy).not_to permit(support_user, nil)
      # end
      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end
  end

  permissions :destroy? do
    context 'when user has a support role' do
      let(:role) { 'support' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a technical role' do
      let(:role) { 'technical' }

      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a business role' do
      let(:role) { 'business' }

      # it 'denies access' do
      #   expect(policy).not_to permit(support_user, nil)
      # end
      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end

    context 'when the user has a researcher role' do
      let(:role) { 'researcher' }

      # it 'denies access' do
      #   expect(policy).not_to permit(support_user, nil)
      # end
      it 'permits access' do
        expect(policy).to permit(support_user, nil)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe SupportUsersHelper, type: :helper do
  describe '#support_user_account_management_path' do
    context 'for a support user' do
      it 'returns the path to remove a support user' do
        support_user = instance_double(SupportUser, id: 12345, discarded?: false)
        path = helper.support_user_account_management_path(support_user)
        expect(path).to eq(support_interface_confirm_destroy_support_user_path(support_user))
      end
    end

    context 'for a discarded support user' do
      it 'returns the path to restore a support user' do
        support_user = instance_double(SupportUser, id: 12345, discarded?: true)
        path = helper.support_user_account_management_path(support_user)
        expect(path).to eq(support_interface_confirm_restore_support_user_path(support_user))
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::FieldsForProviderUserPermissionsForm do
  let(:view_applications_only) { 'false' }
  let(:permissions) { %w[manage_users] }
  let(:provider_id) { '123' }
  let(:attrs) do
    {
      'view_applications_only' => view_applications_only,
      'permissions' => permissions,
      'provider_id' => provider_id,
    }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:view_applications_only).with_message('Choose whether this user has extra permissions') }

    context 'when view_applications_only is false' do
      let(:permissions) { [''] }

      it 'validates that there are selected permissions' do
        form = described_class.new(attrs)

        expect(form).to be_invalid
        expect(form.errors[:permissions]).to contain_exactly('Select extra permissions')
      end
    end

    context 'when view_applications_only is true' do
      let(:permissions) { [''] }
      let(:view_applications_only) { 'true' }

      it 'does not validate the extra permissions' do
        form = described_class.new(attrs)

        expect(form).to be_valid
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionsForm do
  let(:ratifying_provider_permissions) { create(:ratifying_provider_permissions) }
  let(:training_provider_permissions) { create(:training_provider_permissions) }

  subject(:form) do
    described_class.new(
      ratifying_provider_permissions: ratifying_provider_permissions,
      training_provider_permissions: training_provider_permissions,
    )
  end

  describe '#assign_permissions_attributes' do
    it 'assigns permissions attributes for accredited and training permissions' do
      allow(ratifying_provider_permissions).to receive(:assign_attributes)
      allow(training_provider_permissions).to receive(:assign_attributes)

      form.assign_permissions_attributes({ training_provider_permissions: { view_safeguarding_information: 'true' } })
      expect(ratifying_provider_permissions).to have_received(:assign_attributes)
        .with({ make_decisions: false, view_safeguarding_information: false })

      expect(training_provider_permissions).to have_received(:assign_attributes)
        .with({ make_decisions: false, view_safeguarding_information: true })
    end
  end

  describe '#update!' do
    let(:permissions_attrs) do
      { training_provider_permissions: { view_safeguarding_information: 'true' } }
    end
    let(:the_time) { Time.current }

    before do
      allow(ratifying_provider_permissions).to receive(:update!).and_return(true)
      allow(training_provider_permissions).to receive(:update!).and_return(true)
      allow(Time).to receive(:current).and_return(the_time)
    end

    it 'updates accredited and training provider permissions models' do
      form.update!(permissions_attrs)

      expect(ratifying_provider_permissions).to have_received(:update!)
        .with({ make_decisions: false, view_safeguarding_information: false, setup_at: the_time })
      expect(training_provider_permissions).to have_received(:update!)
        .with({ make_decisions: false, view_safeguarding_information: true, setup_at: the_time })
    end
  end
end

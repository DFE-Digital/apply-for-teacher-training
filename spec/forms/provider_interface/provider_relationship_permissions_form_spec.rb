require 'rails_helper'

RSpec.describe ProviderInterface::ProviderRelationshipPermissionsForm do
  let(:accredited_body_permissions) { create(:accredited_body_permissions) }
  let(:training_provider_permissions) { create(:training_provider_permissions) }

  subject(:form) do
    described_class.new(
      accredited_body_permissions: accredited_body_permissions,
      training_provider_permissions: training_provider_permissions,
    )
  end

  describe '#assign_permissions_attributes' do
    it 'assigns permissions attributes for accredited and training permissions' do
      allow(accredited_body_permissions).to receive(:assign_attributes)
      allow(training_provider_permissions).to receive(:assign_attributes)

      form.assign_permissions_attributes({ training_provider_permissions: { view_safeguarding_information: 'true' } })
      expect(accredited_body_permissions).to have_received(:assign_attributes)
        .with({ make_decisions: false, view_safeguarding_information: false })

      expect(training_provider_permissions).to have_received(:assign_attributes)
        .with({ make_decisions: false, view_safeguarding_information: true })
    end
  end

  describe '#save!' do
    before do
      allow(accredited_body_permissions).to receive(:save!).and_return(true)
      allow(training_provider_permissions).to receive(:save!).and_return(true)
    end

    it 'saves accredited and training provider permissions models' do
      form.save!

      expect(accredited_body_permissions).to have_received(:save!)
      expect(training_provider_permissions).to have_received(:save!)
    end

    it 'assigns current time to setup_at attribute' do
      the_time = Time.current
      allow(accredited_body_permissions).to receive(:setup_at=)
      allow(training_provider_permissions).to receive(:setup_at=)
      allow(Time).to receive(:current).and_return(the_time)

      form.save!

      expect(accredited_body_permissions).to have_received(:setup_at=).with(the_time)
      expect(training_provider_permissions).to have_received(:setup_at=).with(the_time)
    end
  end
end

require 'rails_helper'

RSpec.describe DataMigrationRunner do
  before do
    test_service = Class.new do
      const_set(:TIMESTAMP, 20210311005059)
      const_set(:MANUAL_RUN, false)

      def change; end
    end

    stub_const('TestService', test_service)
  end

  it 'throws an NameError if the service does not exist' do
    expect { described_class.new('NoSuchClass') }.to raise_error(NameError)
  end

  context 'when the service has already been migrated' do
    it 'throws a MigrationAlreadyRanError' do
      DataMigration.create(service_name: TestService.to_s, timestamp: TestService::TIMESTAMP)

      expect { described_class.new(TestService.to_s) }.to raise_error(DataMigrationRunner::MigrationAlreadyRanError)
    end
  end

  context 'when the service has not been migrated before' do
    it 'executes the migration and updates the DataMigration table' do
      service = described_class.new(TestService.to_s)

      expect { service.execute }
        .to change { DataMigration.where(service_name: TestService.to_s, timestamp: TestService::TIMESTAMP).count }.by(1)
    end

    it 'adds an audit entry', with_audited: true do
      service = described_class.new(TestService.to_s)

      expect { service.execute }
        .to change { Audited::Audit.count }.by(1)
    end
  end

  context 'when Service::MANUAL_RUN is set to false' do
    context 'when manual: true' do
      it 'throws a AutomatedRanOnlyError' do
        expect { described_class.new(TestService.to_s, manual: true) }.to raise_error(DataMigrationRunner::AutomatedRanOnlyError)
      end
    end
  end

  context 'when Service::MANUAL_RUN is set to true' do
    before do
      test_service = Class.new do
        const_set(:TIMESTAMP, 20210311005059)
        const_set(:MANUAL_RUN, true)

        def change; end
      end

      stub_const('TestManualService', test_service)
    end

    context 'when manual: false' do
      it 'throws a ManualRanOnlyError' do
        expect { described_class.new(TestManualService.to_s, manual: false) }.to raise_error(DataMigrationRunner::ManualRanOnlyError)
      end
    end

    context 'when manual: true' do
      it 'executes the service' do
        service = described_class.new(TestManualService.to_s, manual: true)

        expect { service.execute }
          .to change { DataMigration.where(service_name: TestManualService.to_s, timestamp: TestManualService::TIMESTAMP).count }.by(1)
      end
    end
  end
end

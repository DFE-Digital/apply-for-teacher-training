require 'rails_helper'

RSpec.describe SafePerformAsync do
  describe '#perform_async' do
    let!(:create_sidekiq_module_ok) do
      # super() call in SafePerformAsync requires an ancestor,
      # which is only possible with a named module, hence stub_const
      stub_const(
        'DummySidekiqModuleOk',
        Module.new do
          def perform_async
            'from_ancestor_method'
          end
        end,
      )
    end

    let(:worker) do
      Class.new do
        extend DummySidekiqModuleOk
        include SafePerformAsync
      end
    end

    it 'delegates to pre-existing #perform_async' do
      allow(worker).to receive(:perform_async)
      worker.perform_async
      expect(worker).to have_received(:perform_async)
    end

    it 'requires/runs pre-existing #perform_async' do
      expect(worker.perform_async).to eq('from_ancestor_method')
    end
  end

  describe 'Redis error handling' do
    let!(:create_sidekiq_module_redis_error) do
      # super() call in SafePerformAsync requires an ancestor,
      # which is only possible with a named module, hence stub_const
      stub_const(
        'DummySidekiqModuleRedisError',
        Module.new do
          def perform_async
            raise Redis::CommandError, 'OOM command not allowed when used memory > \'maxmemory\'.'
          end
        end,
      )
    end

    let(:worker) do
      Class.new do
        extend DummySidekiqModuleRedisError
        include SafePerformAsync
      end
    end

    it 'rescues any Redis::BaseError and notifies Sentry' do
      allow(Sentry).to receive(:capture_exception)
      expect { worker.perform_async }.not_to raise_error
      expect(Sentry).to have_received(:capture_exception)
    end
  end
end

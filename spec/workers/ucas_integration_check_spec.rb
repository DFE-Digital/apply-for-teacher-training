require 'rails_helper'

RSpec.describe UCASIntegrationCheck do
  before { allow(Sentry).to receive(:capture_exception) }

  describe '#perform' do
    context 'detect_ucas_match_upload_failure' do
      it 'detects a ucas match file upload failure' do
        UCASMatching::FileDownloadCheck.set_last_sync(3.days.ago)

        described_class.new.perform

        expect(Sentry).to have_received(:capture_exception).with(
          UCASIntegrationCheck::UCASMatchingFileDownloadFailure.new(
            'There was no UCAS file download taking place yesterday',
          ),
        )
      end

      it 'does not raise an error if the file wa uploaded successfully' do
        UCASMatching::FileDownloadCheck.set_last_sync(1.hour.ago)

        described_class.new.perform

        expect(Sentry).not_to have_received(:capture_exception)
      end
    end
  end
end

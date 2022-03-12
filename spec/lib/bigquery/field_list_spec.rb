require 'rails_helper'

RSpec.describe Bigquery::FieldList do
  context 'with dummy data' do
    let(:existing_allowlist) { { candidates: ['email_address'] } }
    let(:existing_blocklist) { { candidates: ['id'] } }

    before do
      allow(Rails.configuration).to receive(:analytics).and_return(existing_allowlist)
      allow(Rails.configuration).to receive(:analytics_blocklist).and_return(existing_blocklist)
    end

    describe '.allowlist' do
      it 'returns all the fields in the analytics.yml file' do
        expect(described_class.allowlist).to eq(existing_allowlist)
      end
    end

    describe '.blocklist' do
      it 'returns all the fields in the analytics_blocklist.yml file' do
        expect(described_class.blocklist).to eq(existing_blocklist)
      end
    end

    describe '.unlisted_fields' do
      it 'returns all the fields in the model that aren’t in either list' do
        fields = described_class.unlisted_fields[:candidates]
        expect(fields).to include('course_from_find_id')
        expect(fields).not_to include('email_address')
        expect(fields).not_to include('id')
      end
    end

    describe '.generate_blocklist' do
      it 'returns all the fields in the model that aren’t in the allowlist' do
        fields = described_class.generate_blocklist[:candidates]
        expect(fields).to include('course_from_find_id')
        expect(fields).to include('id')
        expect(fields).not_to include('email_address')
      end
    end

    describe '.surplus_fields' do
      it 'returns nothing' do
        fields = described_class.surplus_fields[:candidates]
        expect(fields).to be_nil
      end
    end

    context 'when the lists deal with an attribute that is no longer in the database' do
      let(:existing_allowlist) { { candidates: ['some_removed_field'] } }

      describe '.surplus_fields' do
        it 'returns the field that has been removed' do
          fields = described_class.surplus_fields[:candidates]
          expect(fields).to eq ['some_removed_field']
        end
      end
    end
  end

  specify 'all fields in the database are covered by the blocklist or allowlist' do
    unlisted_fields = described_class.unlisted_fields

    failure_message = <<~HEREDOC
      New database field detected! You need to decide whether or not to send it
      to BigQuery. To send, add it to config/analytics.yml. To ignore, run:

      bundle exec rails bigquery:regenerate_blocklist

      New fields: #{unlisted_fields.inspect}
    HEREDOC

    expect(unlisted_fields).to be_empty, failure_message
  end

  specify 'the allowlist deals only with fields in the database' do
    surplus_fields = described_class.surplus_fields

    failure_message = <<~HEREDOC
      Database field removed! Please remove it from analytics.yml and then run

      bundle exec rails bigquery:regenerate_blocklist

      Removed fields: #{surplus_fields.inspect}
    HEREDOC

    expect(surplus_fields).to be_empty, failure_message
  end
end

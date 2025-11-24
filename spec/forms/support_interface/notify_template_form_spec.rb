require 'rails_helper'

RSpec.describe SupportInterface::NotifyTemplateForm do
  describe 'attributes' do
    it do
      expect(described_class.new).to have_attributes(
        template_id: nil,
        attachment: nil,
        distribution_list: nil,
        support_user: nil,
        invalid_email_address_rows: nil,
        valid_email_addresses: nil,
      )
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:template_id) }
    it { is_expected.to validate_presence_of(:attachment) }
    it { is_expected.to validate_presence_of(:distribution_list) }

    describe '#valid_template_id' do
      let(:form) { described_class.new(template_id: '123456') }

      context 'when the template does include personalisation ((link_to_file))' do
        before do
          stub_request(:get, 'https://api.notifications.service.gov.uk/v2/template/123456')
            .to_return(status: 200, body: { body: '((link_to_file))' }.to_json, headers: {})
        end

        it "does not add validation error for the notify template" do
          form.valid?
          expect(form.errors[:template_id]).not_to include('Please enter a valid notify template id')
        end
      end

      context 'when the template does not include personalisation ((link_to_file))' do
        before do
          stub_request(:get, 'https://api.notifications.service.gov.uk/v2/template/123456')
            .to_return(status: 200, body: '', headers: {})
        end

        it 'adds a validation error' do
          expect(form).not_to be_valid
          expect(form.errors[:template_id]).to include('Please enter a valid notify template id')
        end
      end
    end

    describe '#distribution_list_format' do
      let(:form) {
        described_class.new(
          distribution_list: instance_double(
            ActionDispatch::Http::UploadedFile,
            size: 1.megabyte,
            read: File.open("spec/fixtures/send_notify_template/distribution_list.csv").read,
            content_type:,
          ),
        )
      }

      context 'when the distribution list is a CSV' do
        let(:content_type) { 'text/csv' }

        it 'does not add a validation error for the distribution_list file type' do
          form.valid?
          expect(form.errors[:distribution_list]).not_to include('Distribution list must be a CSV file')
        end
      end

      context 'when the distribution list is not a CSV' do
        let(:content_type) { 'image/jpeg' }

        it "adds a validation error" do
          expect(form).not_to be_valid
          expect(form.errors[:distribution_list]).to include('Distribution list must be a CSV file')
        end
      end
    end

    describe '#distribution_list_header' do
      let(:form) {
        described_class.new(
          distribution_list: instance_double(
            ActionDispatch::Http::UploadedFile,
            size: 1.megabyte,
            read: File.open(file_path).read,
            content_type: 'text/csv',
            ),
          )
      }

      context 'when the distribution list has the correct headers' do
        let(:file_path) { 'spec/fixtures/send_notify_template/distribution_list.csv' }

        it 'does not add a validation error for the distribution_list file type' do
          form.valid?
          expect(form.errors[:distribution_list]).not_to include('Your file needs a column called ‘Email address’.')
        end
      end

      context 'when the distribution list does not contain the correct headers' do
        let(:file_path) { 'spec/fixtures/send_notify_template/distribution_list_with_invalid_headers.csv' }

        it 'adds a validation error' do
          expect(form).not_to be_valid
          expect(form.errors[:distribution_list]).to include('Your file needs a column called ‘Email address’.')
        end
      end
    end

    describe '#distribution_list_email_addresses' do
      let(:form) {
        described_class.new(
          distribution_list: instance_double(
            ActionDispatch::Http::UploadedFile,
            size: 1.megabyte,
            read: File.open(file_path).read,
            content_type: 'text/csv',
            ),
          )
      }

      context 'when the distribution list has valid email addresses' do
        let(:file_path) { 'spec/fixtures/send_notify_template/distribution_list.csv' }

        it 'does not add a validation error for the distribution_list containing invalid email addresses' do
          form.valid?
          expect(form.errors[:distribution_list]).not_to include('Distribution list contains invalid email addresses')
        end
      end

      context 'when the distribution list does not contain valid email addresses' do
        let(:file_path) { 'spec/fixtures/send_notify_template/distribution_list_with_invalid_email_addresses.csv' }

        it 'adds a validation error' do
          expect(form).not_to be_valid
          expect(form.errors[:distribution_list]).to include('Distribution list contains invalid email addresses')
        end
      end
    end

    describe "#attachment_size" do
      let(:form) {
        described_class.new(
          attachment: instance_double(
            ActionDispatch::Http::UploadedFile,
            size:,
            read: File.open('spec/fixtures/send_notify_template/hello_world.txt').read,
            content_type: 'text/csv',
            ),
          )
      }

      context 'when the attachment size is less than 2 megabytes' do
        let(:size) { 1.megabyte }

        it 'does not add a validation error for the attachment being too large' do
          form.valid?
          expect(form.errors[:attachment]).not_to include('Please upload an attachment smaller than 2MB')
        end
      end

      context 'when the attachment size is 2 megabytes or larger' do
        let(:size) { 2.megabytes }

        it 'adds a validation error' do
          expect(form).not_to be_valid
          expect(form.errors[:attachment]).to include('Please upload an attachment smaller than 2MB')
        end
      end
    end
  end
end

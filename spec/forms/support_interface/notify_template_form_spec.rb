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
      let(:notify_template) { instance_double(Notifications::Client::Template) }

      before do
        notify_client = instance_double(Notifications::Client)
        allow(Notifications::Client).to receive(:new).and_return(notify_client)
        allow(notify_client).to receive(:get_template_by_id).and_return(notify_template)
      end

      context 'when the template does include personalisation ((link_to_file))' do
        before do
          allow(notify_template).to receive(:body).and_return('((link_to_file))')
        end

        it 'does not add validation error for the notify template' do
          form.valid?
          expect(form.errors[:template_id]).not_to include('Enter a valid notify template id')
        end
      end

      context 'when the template does not include personalisation ((link_to_file))' do
        before do
          allow(notify_template).to receive(:body).and_raise(StandardError)
        end

        it 'adds a validation error' do
          expect(form).not_to be_valid
          expect(form.errors[:template_id]).to include('Enter a real template id')
        end
      end
    end

    describe '#distribution_list_format' do
      let(:form) {
        described_class.new(
          distribution_list: instance_double(
            ActionDispatch::Http::UploadedFile,
            size: 1.megabyte,
            read: File.read('spec/fixtures/send_notify_template/distribution_list.csv'),
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

        it 'adds a validation error' do
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
            read: File.read(file_path),
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
          expect(form.errors[:distribution_list]).to include('Distribution list must include the column header Email address.')
        end
      end
    end

    describe '#distribution_list_email_addresses' do
      let(:form) {
        described_class.new(
          distribution_list: instance_double(
            ActionDispatch::Http::UploadedFile,
            size: 1.megabyte,
            read: File.read(file_path),
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

    describe '#attachment_size' do
      let(:form) {
        described_class.new(
          attachment: instance_double(
            ActionDispatch::Http::UploadedFile,
            size:,
            original_filename: 'file.csv',
            read: File.read('spec/fixtures/send_notify_template/hello_world.txt'),
            content_type: 'text/csv',
          ),
        )
      }

      context 'when the attachment size is less than 2 megabytes' do
        let(:size) { 1.megabyte }

        it 'does not add a validation error for the attachment being too large' do
          form.valid?
          expect(form.errors[:attachment]).not_to include('Upload an attachment smaller than 2MB')
        end
      end

      context 'when the attachment size is 2 megabytes or larger' do
        let(:size) { 2.megabytes }

        it 'adds a validation error' do
          expect(form).not_to be_valid
          expect(form.errors[:attachment]).to include('The file attachment must be 2MB or smaller.')
        end
      end
    end

    describe '#attachment_name' do
      let(:form) {
        described_class.new(
          attachment: instance_double(
            ActionDispatch::Http::UploadedFile,
            size: 1.megabyte,
            original_filename:,
            read: File.read('spec/fixtures/send_notify_template/hello_world.txt'),
            content_type: 'text/csv',
          ),
        )
      }

      context 'when the attachment name is 100 characters or less' do
        let(:original_filename) { 'file.txt' }

        it 'does not add a validation error for the attachment file name being too large' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include('The file name of your attachment must be 100 characters or fewer.')
        end
      end

      context 'when the attachment name is more than 100 characters' do
        let(:original_filename) { "#{'a' * 101}.txt" }

        it 'adds a validation error' do
          expect(form).not_to be_valid
          expect(
            form.errors[:attachment],
          ).to include('The file name of your attachment must be 100 characters or fewer.')
        end
      end
    end

    describe '#attachment_type' do
      let(:form) {
        described_class.new(
          attachment: instance_double(
            ActionDispatch::Http::UploadedFile,
            size: 1.megabyte,
            original_filename:,
            read: File.read('spec/fixtures/send_notify_template/hello_world.txt'),
            content_type:,
          ),
        )
      }

      # csv jpeg jpg png xlsx doc docx pdf json odt rtf txt

      context 'when the attachment file name extension is csv' do
        let(:original_filename) { 'file.csv' }
        let(:content_type) { 'text/csv' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is jpeg' do
        let(:original_filename) { 'file.jpeg' }
        let(:content_type) { 'image/jpeg' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is png' do
        let(:original_filename) { 'file.png' }
        let(:content_type) { 'image/png' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is xlsx' do
        let(:original_filename) { 'file.xlsx' }
        let(:content_type) { 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is doc' do
        let(:original_filename) { 'file.doc' }
        let(:content_type) { 'application/msword' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is docx' do
        let(:original_filename) { 'file.docx' }
        let(:content_type) { 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is pdf' do
        let(:original_filename) { 'file.pdf' }
        let(:content_type) { 'application/pdf' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is json' do
        let(:original_filename) { 'file.json' }
        let(:content_type) { 'application/json' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is odt' do
        let(:original_filename) { 'file.odt' }
        let(:content_type) { 'application/vnd.oasis.opendocument.text' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is rtf' do
        let(:original_filename) { 'file.rtf' }
        let(:content_type) { 'application/rtf' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is txt' do
        let(:original_filename) { 'file.txt' }
        let(:content_type) { 'text/plain' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).not_to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end

      context 'when the attachment file name extension is an invalid extension' do
        let(:original_filename) { 'file.fake' }
        let(:content_type) { 'text/fake' }

        it 'does not add a validation error for the attachment type being invalid' do
          form.valid?
          expect(
            form.errors[:attachment],
          ).to include(
            'The file attachment must be one of the following file types: .csv, .jpeg, .jpg, .png, .xlsx, .doc, .docx, .pdf, .json, .odt, .rtf, .txt',
          )
        end
      end
    end
  end
end

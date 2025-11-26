module SupportInterface
  class NotifyTemplateForm
    include ActiveModel::Model

    VALID_HEADERS = ['Email address'].freeze

    attr_accessor :template_id,
                  :attachment,
                  :distribution_list,
                  :support_user,
                  :invalid_email_address_rows,
                  :valid_email_addresses

    validates :template_id, presence: true
    validate :valid_template_id, if: :template_id_present?
    validates :distribution_list, presence: true
    validate :distribution_list_format, if: :distribution_list_present?
    validate :distribution_list_malformed, if: :distribution_list_present?
    validate :distribution_list_header, if: :csv_correctly_formatted?
    validate :distribution_list_email_addresses, if: :csv_correctly_formatted?
    validates :attachment, presence: true
    validate :attachment_size, if: :attachment_present?

    delegate :present?, to: :template_id, prefix: true
    delegate :present?, to: :distribution_list, prefix: true
    delegate :present?, to: :attachment, prefix: true

    def valid_template_id
      template = notify_client.get_template_by_id(template_id)
      return if template.body.include?('((link_to_file))')

      errors.add(:template_id, :template_missing_personalisation)
    rescue StandardError
      errors.add(:template_id, :invalid)
    end

    def distribution_list_format
      errors.add(:distribution_list, :invalid) unless csv_format?
    end

    def distribution_list_malformed
      return unless csv_format?

      errors.add(:distribution_list, :malformed) if csv_malformed?
    end

    def distribution_list_header
      return if missing_columns.empty?

      errors.add(:distribution_list,
                 :invalid_headers,
                 missing_columns: missing_columns.map { |string| "‘#{string}’" }.to_sentence)
    end

    def distribution_list_email_addresses
      return if missing_columns.any?

      self.invalid_email_address_rows ||= []
      self.valid_email_addresses ||= []
      csv.each_with_index do |row, index|
        email_address = row['Email address'].strip
        recipient = Recipient.new(email_address:)
        if recipient.valid?
          self.valid_email_addresses << email_address
        else
          self.invalid_email_address_rows << { row_number: index + 2, email_address: }
        end
      end

      return if invalid_email_address_rows.blank?

      errors.add(:distribution_list, :invalid_email_addresses)
    end

    def attachment_size
      errors.add(:attachment, :invalid_size) if attachment.size >= 2.megabytes
    end

    def create_request!
      request = SupportInterface::NotifySendRequest.new(
        template_id:,
        email_addresses: valid_email_addresses.uniq,
        support_user: support_user,
      )
      request.file.attach(attachment)
      request.save!

      request
    end

  private

    def csv_correctly_formatted?
      csv_format? && !csv_malformed?
    end

    def csv_format?
      @csv_format ||= distribution_list&.content_type == 'text/csv'
    end

    def valid_header?
      csv.headers
    end

    def csv_malformed?
      @csv_not_malformed ||= begin
        csv
        false
      rescue CSV::MalformedCSVError
        true
      end
    end

    def missing_columns
      @missing_columns ||= begin
        csv_headers = csv.headers
        VALID_HEADERS - csv_headers
      end
    end

    def csv
      @csv ||= CSV.parse(
        distribution_list.read,
        headers: true,
        skip_blanks: true,
        encoding: 'iso-8859-1:utf-8',
      )
    end

    def notify_client
      @notify_client ||= Notifications::Client.new(ENV.fetch('GOVUK_NOTIFY_API_KEY'))
    end

    class Recipient
      include ActiveModel::Model

      attr_accessor :email_address

      validates :email_address, valid_for_notify: true
    end
  end
end

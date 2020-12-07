require 'csv'
require 'ruby_postal/parser'

module ProviderInterface
  class InternationalAddressLineConverter
    # Read addresses file [application_form.id, international_address]
    # Parse addresses
    # Omit unparseable or invalid results
    # Write addresses to file [application_form.id, address_line1, address_line2, address_line3, address_line4]

    TRIBAL_MAX_ADDRESS_LENGTH = 50
    MAX_ADDRESS_LINES = 4
    FIELDS = %i[
      po_box unit level house house_number road
      suburb city_district city state_district state
      postcode
    ].freeze

    def convert(address_file_name)
      parsed_addresses = {}

      raw_addresses = File.read(address_file_name).split("\n###\n").map(&:strip)
      raw_addresses.each do |raw_address|
        id, address = raw_address.split('||')
        parsed_addresses[id] = Postal::Parser.parse_address(address.strip) if address.present?
      end

      converted_address_set = {}
      parsed_addresses.each { |k, a| converted_address_set[k] = address_lines(a) }

      CSV.open("#{address_file_name}.converted.csv", 'wb') do |csv|
        csv << %w[id address_line1 address_line2 address_line3 address_line4]
        converted_address_set.each do |id, address_lines|
          if address_lines.blank?
            Rails.logger.info "Address(#{id}) has no usable data."
            next
          end

          if address_lines.present? && has_four_lines_or_less?(address_lines)
            csv << [id] + address_lines
          else
            Rails.logger.info "Address (#{id}) has more than #{MAX_ADDRESS_LINES} lines."
            Rails.logger.info address_lines
          end
        end
      end

      Rails.logger.info score(converted_address_set.values)
    end

    def import
      CSV.read("#{address_file_name}.converted.csv", headers: true) do |row|
        application_form = ApplicationForm.find_by_id(row['id'])

        if application_form.address_line1.blank? && application_form.address_line2.blank? &&
            application_form.address_line3.blank? && application_form.address_line4.blank?
          application_form.update!(
            address_line1: csv['address_line1'],
            address_line2: csv['address_line2'],
            address_line3: csv['address_line3'],
            address_line4: csv['address_line4'],
            international_address: nil,
            audit_comment: 'Updating address fields from international address',
          )
        end
      end
    end

    def address_lines(address)
      # Parsed address data may contain the same label twice eg. [{ label: :road 'Here' }, { label: :road, 'There' }]
      concatenated_fields = {}
      FIELDS.each do |field|
        concatenated_fields[field] = address.select { |a| a[:label] == field && a[:value].present? }.map { |h| h[:value] }.join(' ').squish
      end

      lines = [
        concatenated_fields.slice(:po_box, :unit, :level, :house, :house_number, :road).values.compact.join(' ').squish,
        concatenated_fields.slice(:suburb, :city_district, :city, :state_district, :state).values.compact.join(' ').squish,
        concatenated_fields[:postcode].squish,
      ].reject(&:blank?)

      return lines if has_lines_of_acceptable_length?(lines)

      split_lines = []
      parts = []

      lines.each do |line|
        next if line.length <= TRIBAL_MAX_ADDRESS_LENGTH

        line.split(' ').each do |word|
          if (parts + [word]).join(' ').length > TRIBAL_MAX_ADDRESS_LENGTH
            split_lines << parts.join(' ')
            parts = [word]
          else
            parts << word
          end
        end
      end

      split_lines << parts.join(' ')
      split_lines.reject(&:blank?)
    end

    def valid?(address)
      has_four_lines_or_less?(address) && has_lines_of_acceptable_length?(address)
    end

    def has_four_lines_or_less?(address)
      address.compact.count <= MAX_ADDRESS_LINES
    end

    def has_lines_of_acceptable_length?(address)
      address.compact.all? { |a| a.length <= TRIBAL_MAX_ADDRESS_LENGTH }
    end

    def score(address_set)
      passing = address_set.select { |a| valid?(a) }.count
      too_many_lines = address_set.reject { |a| has_four_lines_or_less?(a) }.count
      lines_too_long = address_set.reject { |a| has_lines_of_acceptable_length?(a) }.count
      {
        total_addresses: address_set.count,
        passing_addresses: passing,
        too_many_lines: too_many_lines,
        lines_too_long: lines_too_long,
      }
    end
  end
end

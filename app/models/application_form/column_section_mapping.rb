class ApplicationForm
  module ColumnSectionMapping
    def by_column(*column_names)
      mapping = ActiveSupport::HashWithIndifferentAccess.new({
        # Personal information
        'date_of_birth' => 'personal_information',
        'first_name' => 'personal_information',
        'last_name' => 'personal_information',

        # Contact Information
        'phone_number' => 'contact_information',
        'address_line1' => 'contact_information',
        'address_line2' => 'contact_information',
        'address_line3' => 'contact_information',
        'address_line4' => 'contact_information',
        'country' => 'contact_information',
        'postcode' => 'contact_information',
        'region_code' => 'contact_information',

        # Interview Preferences
        'interview_preferences' => 'interview_preferences',

        # Disability
        'disability_disclosure' => 'disability_disclosure',
      })

      return mapping[column_names.first] if column_names.length == 1

      Array(column_names).each_with_object([]) do |column_name, set|
        set << mapping[column_name]
      end.uniq
    end

    def by_section(*sections)
      mapping = ActiveSupport::HashWithIndifferentAccess.new({
        # Personal information
        'personal_information' => %w[
          date_of_birth
          first_name
          last_name
        ],

        # Contact Information
        'contact_information' => %w[
          phone_number
          address_line1
          address_line2
          address_line3
          address_line4
          country
          postcode
          region_code
        ],

        # Interview Preferences
        'interview_preferences' => ['interview_preferences'],

        # Disability
        'disability_disclosure' => ['disability_disclosure'],
      })

      Array(sections).flat_map do |section|
        mapping[section]
      end.compact
    end
    module_function :by_column, :by_section
  end
end

module ProviderInterface
  class UserPersonalDetailsComponent < SummaryListComponent
    def initialize(user:, change_path: nil)
      @user = user
      @change_path = change_path
    end

    def rows
      %i[first_name last_name email_address].map do |field|
        row_for_field(field)
      end
    end

  private

    attr_accessor :user, :change_path

    def row_for_field(field)
      field_label = field.to_s.humanize
      row = {
        key: field_label,
        value: user.send(field),
      }

      return row if change_path.blank?

      row.merge({
        action: field_label,
        change_path: change_path,
      })
    end
  end
end

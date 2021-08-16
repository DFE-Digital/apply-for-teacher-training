module ProviderInterface
  class UserPermissionsReviewComponent < SummaryListComponent
    def initialize(permissions:, change_path:)
      @permissions = permissions
      @change_path = change_path
    end

    def rows
      ProviderPermissions::VALID_PERMISSIONS.map do |permission|
        permission_description = t("user_permissions.#{permission}.description")
        {
          key: permission_description,
          value: permission_value(permission),
          action: {
            visually_hidden_text: permission_description,
            href: change_path,
          },
        }
      end
    end

  private

    attr_accessor :permissions, :change_path

    def permission_value(permission)
      if permissions.include? permission.to_s
        'Yes'
      else
        'No'
      end
    end
  end
end

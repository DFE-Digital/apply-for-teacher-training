module ProviderInterface
  class FieldsForProviderUserPermissionsForm
    include ActiveModel::Model

    attr_accessor :view_applications_only, :provider_id
    attr_writer :permissions

    alias_method :id, :provider_id

    validates :view_applications_only, presence: { message: 'Choose whether this user has extra permissions' }
    validate :at_least_one_extra_permission_is_set, if: -> { view_applications_only == 'false' }

    def initialize(attrs = {})
      if attrs['view_applications_only'] == 'true'
        attrs['permissions'] = []
      end
      super(attrs)
    end

    def permissions
      @permissions ||= []
    end

  private

    def at_least_one_extra_permission_is_set
      if permissions.reject(&:blank?).none?
        errors[:permissions] << 'Select extra permissions'
      end
    end
  end
end

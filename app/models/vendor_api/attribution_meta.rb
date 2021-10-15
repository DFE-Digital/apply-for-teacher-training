module VendorAPI
  class AttributionMeta
    include ActiveModel::Validations

    attr_accessor :full_name, :email, :user_id

    validates :full_name, :email, :user_id, presence: true
    validates :full_name, length: { maximum: 120 }
    validates :email, :user_id, length: { maximum: 100 }

    def initialize(attrs = {})
      @full_name = attrs[:full_name]
      @email = attrs[:email]
      @user_id = attrs[:user_id]
    end
  end
end

module DataMigrations
  class DropContentSecurityPolicyFeatureFlag
    TIMESTAMP = 20220301171412
    MANUAL_RUN = false

    def change
      Feature.where(name: :content_security_policy).first&.destroy
    end
  end
end

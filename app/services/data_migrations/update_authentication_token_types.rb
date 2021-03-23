module DataMigrations
  class UpdateAuthenticationTokenTypes
    TIMESTAMP = 20210323103052
    MANUAL_RUN = false

    def change
      AuthenticationToken.where(user_type: 'DataAPIUser').update_all(user_type: 'ServiceAPIUser')
    end
  end
end

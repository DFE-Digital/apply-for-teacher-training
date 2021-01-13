class BackupAndRestoreSupportUsers
  REDIS_KEY = 'support_users'.freeze

  def self.backup!
    existing_users = SupportUser.pluck(:email_address, :dfe_sign_in_uid)

    if existing_users.any?
      Redis.new.set(REDIS_KEY, JSON.generate(existing_users))
    end

    existing_users.count
  end

  def self.restore!
    restored_users = JSON.parse(Redis.new.get(REDIS_KEY))

    restored_users.each do |(email, uid)|
      SupportUser.find_or_create_by(email_address: email, dfe_sign_in_uid: uid)
    end

    restored_users.count
  end
end

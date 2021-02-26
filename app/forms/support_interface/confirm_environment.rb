module SupportInterface
  class ConfirmEnvironment
    include ActiveModel::Model
    attr_accessor :from, :environment

    validate :correct_environment

    def correct_environment
      if environment != HostingEnvironment.environment_name
        errors[:environment] << "That’s not ’#{HostingEnvironment.environment_name}’!"
      end
    end
  end
end

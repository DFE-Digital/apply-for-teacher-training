module ProviderInterface
  class PermissionsDebugCommentComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :analysis

    def initialize(auth_analysis:)
      @analysis = auth_analysis
    end

    def formatted_details
      @formatted_details ||= details.map { |s| s.ljust(9, ' ') }
    end

    def permission_name
      analysis.permission.to_s.ljust(37, ' ')
    end

    def ids_block
      "[provider user #{analysis.provider_user.id} vs. course #{analysis.course.id}]".rjust(45, ' ')
    end

  private

    def details
      [
        (analysis.ratified_course? ? '✔' : '✗'),
        (analysis.provider_user_associated_with_training_provider? ? 'Trains' : 'Ratifies'),
        (analysis.provider_user_has_user_level_access? ? '✔' : '✗'),
        (analysis.provider_relationship_allows_access? ? '✔' : '✗'),
        (analysis.provider_relationship_has_been_set_up? ? '✔' : '✗'),
        (analysis.provider_user_can_manage_users? ? '✔' : '✗'),
        (analysis.provider_user_can_manage_organisations? ? '✔' : '✗'),
      ]
    end
  end
end

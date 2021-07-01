module SupportInterface
  class ProviderRelationshipsDiagram
    AVAILABLE_PERMISSIONS = {
      view_safeguarding_information: 'view safeguarding',
      view_diversity_information: 'view diversity',
      make_decisions: 'make decisions',
    }.freeze

    def initialize(provider:)
      @provider = provider
    end

    def svg
      graph = GraphViz.new('G', rankdir: 'TB', ratio: 'fill')

      providers_with_relationships.each do |provider|
        graph.add_nodes(
          "Provider##{provider.id}",
          label: provider.name_and_code,
          width: '0.1',
          height: '0.5',
          shape: 'rect',
          style: 'filled',
          color: @provider == provider ? '#1d70b8' : '#4c2c92',
          fontcolor: '#ffffff',
          fontname: 'GDS Transport", arial, sans-serif',
          fontsize: 11,
          margin: 0.1,
          URL: Rails.application.routes.url_helpers.support_interface_provider_user_list_path(provider),
        )
      end

      providers_with_relationships.each do |provider|
        provider.training_provider_permissions.each do |perm|
          next unless graph.find_node("Provider##{perm.ratifying_provider_id}")

          next unless perm.training_provider_id == @provider.id

          graph.add_edges(
            "Provider##{perm.training_provider_id}",
            "Provider##{perm.ratifying_provider_id}",
            label: translate_training_permissions(perm),
            fontname: 'GDS Transport", arial, sans-serif',
            color: '#0b0c0c',
            fontcolor: '#0b0c0c',
            fontsize: 12,
          )
        end

        provider.ratifying_provider_permissions.each do |perm|
          next unless graph.find_node("Provider##{perm.training_provider_id}")

          next unless perm.ratifying_provider_id == @provider.id

          graph.add_edges(
            "Provider##{perm.ratifying_provider_id}",
            "Provider##{perm.training_provider_id}",
            label: translate_ratifying_permissions(perm),
            fontname: 'GDS Transport", arial, sans-serif',
            color: '#0b0c0c',
            fontcolor: '#0b0c0c',
            fontsize: 12,
          )
        end
      end

      graph[:rankdir] = 'LR'

      graph.output(svg: String).force_encoding('UTF-8').html_safe
    end

  private

    def providers_with_relationships
      @providers_with_relationships ||= providers.select { |provider| provider.training_provider_permissions.any? || provider.ratifying_provider_permissions.any? }
    end

    def providers
      [
        @provider,
        @provider.training_provider_permissions.map(&:ratifying_provider),
        @provider.ratifying_provider_permissions.map(&:training_provider),
      ].flatten
    end

    def translate_training_permissions(permission)
      return 'Permissions not setup' if permissions_not_setup(permission)

      "can #{build_permissions_string(:training_provider, permission)} for courses ratified by"
    end

    def translate_ratifying_permissions(permission)
      return 'Permissions not setup' if permissions_not_setup(permission)

      "can #{build_permissions_string(:ratifying_provider, permission)} for courses run by"
    end

    def value_indicator(permission_value)
      permission_value ? '✅' : '❌'
    end

    def permissions_not_setup(permission)
      permission.setup_at.blank?
    end

    def build_permissions_string(provider_type, permission)
      AVAILABLE_PERMISSIONS.inject([]) do |permissions, (rule, rule_text)|
        permissions << "#{send(:value_indicator, permission.send("#{provider_type}_can_#{rule}"))} #{rule_text}"
      end.join(' ')
    end
  end
end

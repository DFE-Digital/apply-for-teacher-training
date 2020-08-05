module SupportInterface
  class ProviderRelationshipsDiagram
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
          fontname: 'Arial',
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
            label: "can #{translate_training_permissions(perm)} for courses ratified by",
            fontname: 'Arial',
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
            label: "can #{translate_ratifying_permissions(perm)} for courses run by",
            fontname: 'Arial',
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
      "#{permission.training_provider_can_view_safeguarding_information ? '✅ view safeguarding' : '❌ view safeguarding'} #{permission.training_provider_can_make_decisions ? '✅ make decisions' : '❌ make decisions'}"
    end

    def translate_ratifying_permissions(permission)
      "#{permission.ratifying_provider_can_view_safeguarding_information ? '✅ view safeguarding' : '❌ view safeguarding'} #{permission.ratifying_provider_can_make_decisions ? '✅ make decisions' : '❌ make decisions'}"
    end
  end
end

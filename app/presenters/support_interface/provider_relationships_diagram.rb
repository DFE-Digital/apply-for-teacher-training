module SupportInterface
  class ProviderRelationshipsDiagram
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
          color: '#1d70b8',
          fontcolor: '#ffffff',
          fontname: 'Arial',
          fontsize: 11,
          margin: 0.1,
          URL: Rails.application.routes.url_helpers.support_interface_provider_path(provider),
        )

        provider.training_provider_permissions.each do |perm|
          graph.add_edges(
            "Provider##{perm.training_provider_id}",
            "Provider##{perm.ratifying_provider_id}",
            label: "#{translate_permissions(perm)} for courses ratified by",
            fontname: 'Arial',
            color: '#0b0c0c',
            fontcolor: '#0b0c0c',
            fontsize: 11,
          )
        end

        provider.ratifying_provider_permissions.each do |perm|
          graph.add_edges(
            "Provider##{perm.ratifying_provider_id}",
            "Provider##{perm.training_provider_id}",
            label: "#{translate_permissions(perm)} for courses run by",
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

    def providers_without_relationships
      providers - providers_with_relationships
    end

  private

    def providers_with_relationships
      @providers_with_relationships ||= providers.select { |provider| provider.training_provider_permissions.any? || provider.ratifying_provider_permissions.any? }
    end

    def providers
      Provider.includes(
        :training_provider_permissions,
        :ratifying_provider_permissions,
        :courses,
      )
    end

    def translate_permissions(permission)
      "#{permission.view_safeguarding_information ? '✅ view safeguarding' : '❌ view safeguarding'} #{permission.view_safeguarding_information ? '✅ make decisions' : '❌ make decisions'}"
    end
  end
end

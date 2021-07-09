module ProviderInterface
  class OrganisationPermissionsSetupListComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def single
      render OrganisationPermissionsSetupListComponent.new(
        grouped_provider_names: {
          'A university' => [
            'One Uni',
            'Two Uni',
            'Three Uni',
          ],
        },
        continue_button_path: '',
      )
    end

    def multiple
      render OrganisationPermissionsSetupListComponent.new(
        grouped_provider_names: {
          'My university' => [
            'One School',
            'Two School',
            'Three School',
          ],
          'Local SD' => [
            'University of school',
            'Another uni',
          ],
        },
        continue_button_path: '',
      )
    end
  end
end

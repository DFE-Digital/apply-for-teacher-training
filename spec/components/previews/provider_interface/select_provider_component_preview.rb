module ProviderInterface
  class SelectProviderComponentPreview < ViewComponent::Preview
    class FormObject
      include ActiveModel::Model

      attr_accessor :provider_id
    end

    def select_provider
      form_path = ''
      providers = Provider.limit(10)
      form_object = FormObject.new(provider_id: providers.last.id)

      render SelectProviderComponent.new(form_object: form_object,
                                         form_path: form_path,
                                         providers: providers)
    end
  end
end

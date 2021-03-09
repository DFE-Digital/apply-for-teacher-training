class CollectionSelectComponentPreview < ViewComponent::Preview
  class FormObject
    include ActiveModel::Model

    attr_accessor :provider_id
  end

  def select_example
    providers = Provider.limit(10)
    form_object = FormObject.new(provider_id: providers.last.id)

    render CollectionSelectComponent.new(attribute: :provider_id,
                                         collection: providers,
                                         value_method: :id,
                                         text_method: :name_and_code,
                                         hint_method: nil,
                                         form_object: form_object,
                                         form_path: '',
                                         page_title: 'Select provider')
  end
end

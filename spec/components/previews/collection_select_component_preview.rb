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
                                         page_title: 'Select provider',
                                         caption: 'Jane Doe')
  end

  def course_select_example_with_hint
    courses = Course.limit(10)
    form_object = FormObject.new(course_id: courses.last.id)

    render CollectionSelectComponent.new(attribute: :course_id,
                                         collection: courses,
                                         value_method: :id,
                                         text_method: :name_and_code,
                                         hint_method: :description_and_accredited_provider,
                                         bold_labels: false,
                                         form_object: form_object,
                                         form_path: '',
                                         page_title: 'Select course',
                                         caption: 'Jane Doe')
  end
end

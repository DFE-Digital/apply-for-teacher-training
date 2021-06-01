module ModelWithErrorsStubHelper
  def stub_model_instance_with_errors(klass, attrs = {}, error_messages = {})
    errors_double = instance_double(
      ActiveModel::Errors,
      any?: true,
      messages: error_messages,
      merge!: error_messages,
      map: error_messages,
    )

    allow(klass).to receive(:new).and_return(instance_double(klass, attrs.merge(model_name: ActiveModel::Name.new(klass), errors: errors_double)))
  end
end

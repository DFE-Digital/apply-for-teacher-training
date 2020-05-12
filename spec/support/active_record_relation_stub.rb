class ActiveRecordRelationStub
  attr_reader :records
  alias_method :to_a, :records

  # @param model_klass [ActiveRecord::Base] the stubbing association's class
  # @param records [Array] list of records the association holds
  # @param scopes [Array] list of stubbed scopes
  def initialize(model_klass, records, scopes: [])
    @records = records

    scopes.each do |scope|
      raise NotImplementedError, scope unless model_klass.respond_to?(scope)

      define_singleton_method(scope) do
        self
      end
    end
  end

  def order(_hash)
    records
  end
end

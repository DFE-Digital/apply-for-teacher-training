module ProviderInterface
  class ConfirmConditionsWizard
    include Wizard

    attr_accessor :statuses, :offer

    validate :all_conditions_have_a_status_selected

    def conditions
      duplicate_conditions = offer.conditions.map { |condition| duplicate_condition_with_id(condition) }

      return duplicate_conditions if statuses.blank?

      duplicate_conditions.each { |condition| update_status_for(condition) }
    end

    def all_conditions_met?
      conditions.all?(&:met?)
    end

    def any_condition_not_met?
      conditions.any?(&:unmet?)
    end

  private

    def duplicate_condition_with_id(condition)
      condition.dup.tap do |duplicate_condition|
        duplicate_condition.id = condition.id
      end
    end

    def update_status_for(condition)
      new_status = statuses&.dig(condition.id.to_s, 'status')
      condition.status = new_status
    end

    def all_conditions_have_a_status_selected
      conditions.each do |condition|
        next if condition.valid?

        condition.errors.each do |error|
          field_name = "statuses[#{condition.id}][#{error.attribute}]"
          create_method(field_name) { error.message }

          errors.add(field_name, error.message)
        end
      end
    end

    def create_method(name, &block)
      self.class.send(:define_method, name, &block)
    end
  end
end

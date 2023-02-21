module DataMigrations
  class StoreEnumForSkeReason
    TIMESTAMP = 20230220140417
    MANUAL_RUN = false

    def change
      ActiveRecord::Base.transaction do
        SkeCondition.find_each do |ske_condition|
          if (subject = ske_condition.details.delete('language')).present?
            ske_condition.subject = subject
            ske_condition.subject_type = 'language'
          else
            ske_condition.subject = course(ske_condition).subjects.first.name
            ske_condition.subject_type = 'standard'
          end

          ske_condition.reason = new_reason(ske_condition.reason)
          ske_condition.graduation_cutoff_date = (course(ske_condition).start_date - 5.years) if ske_condition.outdated_degree?

          ske_condition.save!
        end
      end
    end

  private

    def new_reason(old_reason)
      if old_reason.include?('degree subject was not')
        'different_degree'
      elsif old_reason.include?('but they graduated before')
        'outdated_degree'
      else
        raise "Unknown reason: #{old_reason}"
      end
    end

    def course(ske_condition)
      ske_condition.offer.course_option.course
    end
  end
end

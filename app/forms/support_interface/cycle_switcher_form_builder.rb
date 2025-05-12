module SupportInterface
  class CycleSwitcherFormBuilder
    def build(attributes = {}, timetable:)
      if attributes.empty?
        build_from_timetable(timetable)
      else
        build_from_form(attributes, timetable:)
      end
    end

  private

    def build_from_form(attributes, timetable:)
      CycleSwitcherForm.new(attributes, timetable:)
    rescue ActiveRecord::MultiparameterAssignmentErrors => e
      e.errors.each do |error|
        attribute_name = error.attribute
        year = attributes["#{attribute_name}(1i)"]
        month = attributes["#{attribute_name}(2i)"]
        day = attributes["#{attribute_name}(3i)"]
        attributes[attribute_name] = Struct.new(:year, :month, :day).new(year, month, day)
        attributes = attributes.except("#{attribute_name}(1i)", "#{attribute_name}(2i)", "#{attribute_name}(3i)")
      end
      build_from_form(attributes, timetable:)
    end

    def build_from_timetable(timetable)
      attrs =
        {
          find_opens_at: timetable.find_opens_at.to_date,
          apply_opens_at: timetable.apply_opens_at.to_date,
          apply_deadline_at: timetable.apply_deadline_at.to_date,
          reject_by_default_at: timetable.reject_by_default_at.to_date,
          decline_by_default_at: timetable.decline_by_default_at.to_date,
          find_closes_at: timetable.find_closes_at.to_date,
        }

      CycleSwitcherForm.new(attrs, timetable:)
    end
  end
end

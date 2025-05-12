module SupportInterface
  class EditableUntilForm
    include ActiveModel::Model
    attr_accessor :application_form, :audit_comment, :audit_comment_description, :policy_confirmation
    attr_writer :sections, :editable_until

    validates :audit_comment, :policy_confirmation, presence: true
    validates_with ZendeskUrlValidator

    def non_editable_sections
      Section.non_editable.insert(2, science_gcse).reject do |section|
        section.id.in?(%i[references safeguarding_issues])
      end.flatten.compact
    end

    def science_gcse
      Section.all.find { |section| section.id == :science_gcse }
    end

    def sections
      Array(current_editable_sections).compact_blank.map(&:to_sym)
    end

    def save
      return false unless valid?

      @application_form.update!(
        editable_sections:,
        editable_until:,
        audit_comment: full_audit,
      )
    end

    def editable_sections
      @sections.compact_blank
    end

    def editable_until
      Rails.configuration.x.sections.editable_window_days.days.from_now.end_of_day if editable_sections.present?
    end

    def full_audit
      return "#{audit_comment} - #{audit_comment_description}" if audit_comment_description.present?

      audit_comment
    end

  private

    def current_editable_sections
      return @sections if @sections.present?

      @application_form.editable_sections if @application_form.editable_until? && Time.zone.now < @application_form.editable_until
    end
  end
end

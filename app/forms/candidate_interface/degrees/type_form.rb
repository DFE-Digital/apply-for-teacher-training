module CandidateInterface
  class Degrees::TypeForm < Degrees::BaseForm
    validates :type, presence: true, length: { maximum: 255 }
    validates :other_type, presence: true, length: { maximum: 255 }, if: :other_type_selected

    def sanitize_attrs(attrs)
      return attrs if attrs[:type].blank?

      if attrs[:type] != 'other'
        attrs[:other_type] = nil
        attrs[:other_type_raw] = nil
      end
      attrs
    end

    def back_link
      if country_with_compatible_degrees? || uk?
        paths.candidate_interface_degree_degree_level_path
      elsif reviewing_and_unchanged_country?
        paths.candidate_interface_degree_review_path
      else
        paths.candidate_interface_degree_country_path
      end
    end

    def next_step
      if reviewing_and_unchanged_country?
        :review
      else
        :subject
      end
    end

    def other_type
      @other_type_raw || @other_type
    end

    def other_type_selected
      type == 'other'
    end
  end
end

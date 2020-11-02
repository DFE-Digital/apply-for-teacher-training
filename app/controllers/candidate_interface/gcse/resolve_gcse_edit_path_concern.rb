module CandidateInterface
  module Gcse
    module ResolveGcseEditPathConcern
      def resolve_gcse_edit_path(subject)
        case subject
        when 'maths'
          Rails.application.routes.url_helpers.candidate_interface_gcse_maths_edit_grade_path
        when 'science'
          candidate_interface_gcse_science_edit_grade_path
        when 'english'
          candidate_interface_gcse_english_edit_grade_path
        end
      end
    end
  end
end

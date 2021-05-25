module CandidateInterface
  module Gcse
    module ResolveGcseEditPathConcern
      def resolve_gcse_edit_path(subject)
        case subject
        when 'maths'
          candidate_interface_new_gcse_maths_grade_path
        when 'science'
          candidate_interface_edit_gcse_science_grade_path
        when 'english'
          candidate_interface_new_gcse_english_grade_path
        end
      end
    end
  end
end

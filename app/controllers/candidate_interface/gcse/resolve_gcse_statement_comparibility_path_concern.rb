module CandidateInterface
  module Gcse
    module ResolveGcseStatementComparibilityPathConcern
      def resolve_gcse_statement_comparibility_path(subject)
        case subject
        when 'maths'
          candidate_interface_new_gcse_maths_statement_comparibility_path(subject:)
        when 'science'
          candidate_interface_new_gcse_science_statement_comparibility_path(subject:)
        when 'english'
          candidate_interface_new_gcse_english_statement_comparibility_path(subject:)
        end
      end

      def resolve_gcse_edit_statement_comparibility_path(subject)
        case subject
        when 'maths'
          candidate_interface_edit_gcse_maths_statement_comparibility_path(subject:)
        when 'science'
          candidate_interface_edit_gcse_science_statement_comparibility_path(subject:)
        when 'english'
          candidate_interface_edit_gcse_english_statement_comparibility_path(subject:)
        end
      end
    end
  end
end

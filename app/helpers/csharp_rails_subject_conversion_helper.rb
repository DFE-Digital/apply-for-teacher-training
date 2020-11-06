# These functions are barely tested and temporary, they should be removed when the results page is filtering in Rails
module CsharpRailsSubjectConversionHelper
  def convert_csharp_subject_id_params_to_subject_code
    subjects = if params["subjects"].is_a?(String)
                 params["subjects"].split(",")
               else
                 params["subjects"]
               end

    subjects&.map do |subject|
      csharp_to_subject_code(id: subject)
    end
  end

  def convert_subject_code_params_to_csharp
    params["subjects"]&.map do |subject|
      subject_code_to_csharp_subject_id(id: subject)
    end
  end

  def csharp_array_to_subject_codes(csharp_id_array)
    csharp_id_array&.map { |csharp_id| csharp_to_subject_code(id: csharp_id) }
  end

  def csharp_to_subject_code(id:)
    rails_data = csharp_subject_code_conversion_table.find do |entry|
      entry[:csharp_id] == id
    end

    # A user may somehow end up with a subject that doesn't exist.
    # If we weren't converting subject IDs, this wouldn't be an issue
    # but since we are, we will just return a subject id that will never exist.
    # This workaround means that removing this entire module will be easier in
    # future because we don't need to do any extra work to ensure a subject
    # exists.
    return "[non-existent subject code]" if rails_data.nil?

    rails_data[:subject_code]
  end

  def subject_code_to_csharp_subject_id(id:)
    csharp_data = csharp_subject_code_conversion_table.find do |entry|
      entry[:subject_code] == id
    end

    return "[non-existent subject id]" if csharp_data.nil?

    csharp_data[:csharp_id]
  end

  def csharp_subject_code_conversion_table
    [{ csharp_id: nil, subject_code: "P1", name: "Philosophy" },
     { csharp_id: nil, subject_code: nil, name: "Modern Languages" },
     { csharp_id: "49", subject_code: "24", name: "Modern languages (other)" },
     { csharp_id: "14", subject_code: "41", name: "Further education" },
     { csharp_id: "44", subject_code: "22", name: "Spanish" },
     { csharp_id: "41", subject_code: "21", name: "Russian" },
     { csharp_id: "23", subject_code: "20", name: "Mandarin" },
     { csharp_id: "21", subject_code: "19", name: "Japanese" },
     { csharp_id: "20", subject_code: "18", name: "Italian" },
     { csharp_id: "16", subject_code: "17", name: "German" },
     { csharp_id: "53", subject_code: "16", name: "English as a second or other language" },
     { csharp_id: "13", subject_code: "15", name: "French" },
     { csharp_id: "43", subject_code: "14", name: "Social sciences" },
     { csharp_id: "40", subject_code: "V6", name: "Religious education" },
     { csharp_id: "39", subject_code: "C8", name: "Psychology" },
     { csharp_id: "30", subject_code: "F3", name: "Physics" },
     { csharp_id: "29", subject_code: "C6", name: "Physical education" },
     { csharp_id: "27", subject_code: "W3", name: "Music" },
     { csharp_id: "24", subject_code: "G1", name: "Mathematics" },
     { csharp_id: "18", subject_code: "V1", name: "History" },
     { csharp_id: "17", subject_code: "L5", name: "Health and social care" },
     { csharp_id: "15", subject_code: "F8", name: "Geography" },
     { csharp_id: "12", subject_code: "Q3", name: "English" },
     { csharp_id: "11", subject_code: "L1", name: "Economics" },
     { csharp_id: "9", subject_code: "13", name: "Drama" },
     { csharp_id: "8", subject_code: "DT", name: "Design and technology" },
     { csharp_id: "7", subject_code: "12", name: "Dance" },
     { csharp_id: "48", subject_code: "11", name: "Computing" },
     { csharp_id: "47", subject_code: "P3", name: "Communication and media studies" },
     { csharp_id: "5", subject_code: "Q8", name: "Classics" },
     { csharp_id: "4", subject_code: "09", name: "Citizenship" },
     { csharp_id: "3", subject_code: "F1", name: "Chemistry" },
     { csharp_id: "2", subject_code: "08", name: "Business studies" },
     { csharp_id: "1", subject_code: "C1", name: "Biology" },
     { csharp_id: "56", subject_code: "F0", name: "Science" },
     { csharp_id: "0", subject_code: "W1", name: "Art and design" },
     { csharp_id: "38", subject_code: "07", name: "Primary with science" },
     { csharp_id: "37", subject_code: "06", name: "Primary with physical education" },
     { csharp_id: "36", subject_code: "04", name: "Primary with modern languages" },
     { csharp_id: "35", subject_code: "03", name: "Primary with mathematics" },
     { csharp_id: "55", subject_code: "02", name: "Primary with geography and history" },
     { csharp_id: "32", subject_code: "01", name: "Primary with English" },
     { csharp_id: "31", subject_code: "00", name: "Primary" }]
  end
end

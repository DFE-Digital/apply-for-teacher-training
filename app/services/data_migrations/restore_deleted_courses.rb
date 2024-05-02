module DataMigrations
  class RestoreDeletedCourses
    TIMESTAMP = 20240502124248
    MANUAL_RUN = true

    def change
      # Add Courses from CSV
      courses_csv = <<~CSV
        id,provider_id,name,code,created_at,updated_at,level,exposed_in_find,recruitment_cycle_year,study_mode,financial_support,start_date,course_length,description,accredited_provider_id,funding_type,age_range,qualifications,program_type,withdrawn,uuid,degree_grade,degree_subject_requirements,accept_pending_gcse,accept_gcse_equivalency,accept_english_gcse_equivalency,accept_maths_gcse_equivalency,accept_science_gcse_equivalency,additional_gcse_equivalencies,applications_open_from,fee_details,fee_international,fee_domestic,salary_details,can_sponsor_skilled_worker_visa,can_sponsor_student_visa,application_status
        58058,55,Mathematics,H902,2023-10-02 23:11:10.880577,2023-10-02 23:11:10.925319,Secondary,f,2024,F,,2024-08-31 23:00:00,,QTS full time teaching apprenticeship,468,apprenticeship,14 to 19,"[""qts""]",TA,f,f21f126b-211b-4dcd-8a4c-52b1f255100c,not_required,,f,f,f,f,f,,2023-10-09 23:00:00,,,,,f,f,0
        58703,2033,Primary,S435,2023-10-02 23:11:16.625958,2023-10-02 23:11:16.660774,Primary,f,2024,F,,2024-08-31 23:00:00,,QTS full time teaching apprenticeship,,apprenticeship,3 to 7,"[""qts""]",TA,f,c6aa2897-b092-4c00-8ba5-d83892624e38,two_two,,t,t,t,t,t,"If you do not hold a GCSE in English, maths or science at grade 4 (C) or above or equivalent you can apply to take an equivalency test. We accept equivalency tests from:

        * [A*Star Teachers](www.astarteachers.co.uk)
        * [Equivalency Testing](www.equivalencytesting.co.uk)
        * [Maths Made Easy](www.mathsmadeeasy.co.uk)",2023-10-09 23:00:00,,,,,f,f,0
        60253,29,Physical Education,368Q,2023-10-02 23:11:28.749743,2023-10-02 23:11:28.772544,Secondary,f,2024,F,,2024-08-31 23:00:00,,PGCE with QTS full time,30,fee,11 to 16,"[""qts"", ""pgce""]",SD,f,f76bda35-b5f5-49bf-9e14-2eafeebcf40f,two_two,,t,t,t,t,,"",2023-10-09 23:00:00,,,,,f,f,0
        60784,475,Primary (Special Educational Needs),2HP5,2023-10-02 23:14:11.375273,2023-10-02 23:14:11.43646,Primary,f,2024,F,,2024-08-31 23:00:00,,PGCE with QTS full time,1071,fee,5 to 11,"[""qts"", ""pgce""]",SD,f,ce437390-2971-412d-bdf6-d7ca31bb91b4,two_two,,t,t,t,t,t,"Any equivalency tests completed must be equivalent to GCSE level. We do not accept adult learning courses as these do not offer the breadth of knowledge that the GCSE curriculums cover.

        We recommend using Edgehill University or those offered by Prestolee SCITT. Links to both of these websites are below:

        https://www.edgehill.ac.uk/study/equivalency/?tab=standalone-tests

        https://www.prestoleescitt.co.uk/Equivalency-Testing/",2023-10-09 23:00:00,,,,,f,f,0
        66304,1417,Primary,2YRM,2023-10-02 23:20:20.991307,2023-10-02 23:20:21.067816,Primary,f,2024,F,,2024-08-31 23:00:00,,QTS full time,1033,fee,5 to 11,"[""qts""]",SD,f,b2483b4f-c3c6-4768-9f64-ef9c602c1d43,two_two,,t,t,t,t,t,"A candidate who does not hold a GCSE at the required grade can either retake a GCSE if time permits, or take
        an equivalency test. At present, we can only accept this from https://www.equivalencytesting.com/.
        ",2023-10-09 23:00:00,,,,,f,f,0
      CSV

      Course.insert_all(CSV.parse(courses_csv, headers: true).map(&:to_h))

      # Add Course Subjects from CSV
      course_subjects_csv = <<~CSV
        id,course_id,subject_id,created_at,updated_at
        66322,58058,26,2023-10-02 23:11:10.891668,2023-10-02 23:11:10.891668
        67003,58703,2,2023-10-02 23:11:16.630919,2023-10-02 23:11:16.630919
        68652,60253,29,2023-10-02 23:11:28.752555,2023-10-02 23:11:28.752555
        69215,60784,2,2023-10-02 23:14:11.383158,2023-10-02 23:14:11.383158
        75066,66304,2,2023-10-02 23:20:20.995782,2023-10-02 23:20:20.995782
      CSV

      CourseSubject.insert_all(CSV.parse(course_subjects_csv, headers: true).map(&:to_h))

      # Add Course Choices from CSV
      course_options_csv = <<~CSV
        id,course_id,vacancy_status,created_at,updated_at,study_mode,site_still_valid,site_id
        153072,58058,vacancies,2023-10-02 23:11:34.449436,2023-10-02 23:11:34.449436,full_time,t,13479781
        155334,58703,vacancies,2023-10-02 23:11:44.244512,2023-10-03 09:47:00.496606,full_time,t,13481975
        155459,58703,vacancies,2023-10-02 23:11:44.697546,2023-10-03 09:47:01.238342,full_time,t,13482125
        160923,60253,vacancies,2023-10-02 23:12:06.523258,2023-10-02 23:12:06.523258,full_time,t,13486326
        163907,60784,no_vacancies,2023-10-02 23:14:27.921326,2023-10-02 23:14:27.921326,full_time,t,13491128
        163916,60784,no_vacancies,2023-10-02 23:14:27.997921,2023-10-02 23:14:27.997921,full_time,t,13491103
        206650,66304,vacancies,2023-10-02 23:20:47.177202,2023-10-02 23:20:47.177202,full_time,t,13522635
      CSV

      CourseOption.insert_all(CSV.parse(course_options_csv, headers: true).map(&:to_h))
    end
  end
end

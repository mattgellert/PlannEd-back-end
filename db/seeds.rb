# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

feb1 = DateTime.new(2017,12,1,17)
feb2 = DateTime.new(2017,12,2,17)
feb3 = DateTime.new(2017,12,3,17)
feb4 = DateTime.new(2017,12,4,17)

math = Course.create({
  crse_id: 1234,
  subject: "MATH",
  catalog_nbr: "1920",
  title: "Math",
  description: "we do a lot of math",
  units_minimum: 4,
  units_maximum: 4,
  session_begin_dt: '08/22/17',
  session_end_dt: '12/08/17'
})
math_instructor = Instructor.create({
  net_id: "mtc1@cornell.edu",
  first_name: "Math",
  last_name: "Teacher"
})

math_1 = Assignment.create({course_id: math.id, title: "math assignment 1", description: "complete the 1st assignment", due_date: feb1})
math_2 = Assignment.create({course_id: math.id, title: "math assignment 2", description: "complete the 2nd assignment", due_date: feb2})
math_3 = Assignment.create({course_id: math.id, title: "math assignment 3", description: "complete the 3rd assignment", due_date: feb3})

english = Course.create({
  crse_id: 1234,
  subject: "ENGL",
  catalog_nbr: "2000",
  title: "English",
  description: "we do a lot of english",
  units_minimum: 4,
  units_maximum: 4,
  session_begin_dt: '08/22/17',
  session_end_dt: '12/08/17'
})
english_instructor = Instructor.create({
  net_id: "etc1@cornell.edu",
  first_name: "English",
  last_name: "Teacher"
})
eng_1 = Assignment.create({course_id: english.id, title: "english assignment 1", description: "complete the 1st assignment", due_date: feb1})
eng_2 = Assignment.create({course_id: english.id, title: "english assignment 2", description: "complete the 2nd assignment", due_date: feb2})
eng_3 = Assignment.create({course_id: english.id, title: "english assignment 3", description: "complete the 3rd assignment", due_date: feb3})

science = Course.create({
  crse_id: 1234,
  subject: "SCI",
  catalog_nbr: "2000",
  title: "Science",
  description: "we do a lot of science",
  units_minimum: 4,
  units_maximum: 4,
  session_begin_dt: '08/22/17',
  session_end_dt: '12/08/17'
})
science_instructor = Instructor.create({
  net_id: "stc1@cornell.edu",
  first_name: "Science",
  last_name: "Teacher"
})

sci_1 = Assignment.create({course_id: science.id, title: "science assignment 1", description: "complete the 1st assignment", due_date: feb1})
sci_2 = Assignment.create({course_id: science.id, title: "science assignment 2", description: "complete the 2nd assignment", due_date: feb2})
sci_3 = Assignment.create({course_id: science.id, title: "science assignment 3", description: "complete the 3rd assignment", due_date: feb4})
sci_3a = Assignment.create({course_id: science.id, title: "science sub assignment 3a", description: "complete the 3a sub-assignment", due_date: feb3, primary_assignment_id: sci_3.id})
sci_3a_1 = Assignment.create({course_id: science.id, title: "science sub assignment 3a_1", description: "complete the 3a_1 sub-assignment", due_date: feb3, primary_assignment_id: sci_3a.id})
sci_3a_1a = Assignment.create({course_id: science.id, title: "science sub assignment 3a_1a", description: "complete the 3a_1a sub-assignment", due_date: feb3, primary_assignment_id: sci_3a_1.id})
sci_3a_1b = Assignment.create({course_id: science.id, title: "science sub assignment 3a_1b", description: "complete the 3a_1b sub-assignment", due_date: feb3, primary_assignment_id: sci_3a_1.id})
sci_3a_1b_1 = Assignment.create({course_id: science.id, title: "science sub assignment 3a_1b_1", description: "complete the 3a_1b_1 sub-assignment", due_date: feb3, primary_assignment_id: sci_3a_1b.id})
matt = Student.create({first_name: "matt", last_name: "gellert", email: "mrg87@cornell.edu"})
shanie = Student.create({first_name: "shanie", last_name: "jeanat", email: "sjeanat@gmail.com"})
eng_3a = Assignment.create({course_id: english.id, title: "english sub assignment 3a", description: "complete the 3a sub-assignment", due_date: feb3, primary_assignment_id: eng_3.id})
# # matt adds math and science
matt_math_course = StudentCourse.create({
  student_id: 1,
  course_id: 1,
  section: "201",
  time_start: "10:00AM",
  time_end: "11:00AM",
  pattern: "MWF",
  facility_descr: "Malott Hall 201",
  facility_descr_short: "MLT 201"
})
matt_math_inst = StudentCourseInstructor.create({
        student_course_id: matt_math_course.id,
        instructor_id: math_instructor.id
      })
matt_math_assignments = StudentAssignment.create([
  {assignment_id: 1, student_course_id: 1},
  {assignment_id: 2, student_course_id: 1},
  {assignment_id: 3, student_course_id: 1}
])
matt_science_course = StudentCourse.create({
  student_id: 1,
  course_id: 3,
  section: "401",
  time_start: "10:00AM",
  time_end: "11:00AM",
  pattern: "MWF",
  facility_descr: "Another Hall 201",
  facility_descr_short: "AHL 201"
})
matt_sci_inst = StudentCourseInstructor.create({
        student_course_id: matt_science_course.id,
        instructor_id: science_instructor.id
      })
matt_science_assignments = StudentAssignment.create([
  {assignment_id: 7, student_course_id: 2},
  {assignment_id: 8, student_course_id: 2},
  {assignment_id: 9, student_course_id: 2},
  {assignment_id: 10, student_course_id: 2},
  {assignment_id: 11, student_course_id: 2},
  {assignment_id: 12, student_course_id: 2},
  {assignment_id: 13, student_course_id: 2},
  {assignment_id: 14, student_course_id: 2}
])


# shanie adds english and science
shanie_english_course = StudentCourse.create({
  student_id: 2,
  course_id: 2,
  section: "301",
  time_start: "10:00AM",
  time_end: "11:00AM",
  pattern: "MWF",
  facility_descr: "English Hall 201",
  facility_descr_short: "ENH 201"
})
shanie_eng_inst = StudentCourseInstructor.create({
        student_course_id: shanie_english_course.id,
        instructor_id: english_instructor.id
      })
shanie_english_assignments = StudentAssignment.create([
  {assignment_id: 4, student_course_id: 3},
  {assignment_id: 5, student_course_id: 3},
  {assignment_id: 6, student_course_id: 3},
  {assignment_id: 15, student_course_id: 3}
])
shanie_science_course = StudentCourse.create({
  student_id: 2,
  course_id: 3,
  section: "401",
  time_start: "10:00AM",
  time_end: "11:00AM",
  pattern: "MWF",
  facility_descr: "Another Hall 201",
  facility_descr_short: "AHL 201"
})
shanie_sci_inst = StudentCourseInstructor.create({
        student_course_id: shanie_science_course.id,
        instructor_id: science_instructor.id
      })
shanie_science_assignments = StudentAssignment.create([
  {assignment_id: 7, student_course_id: 4},
  {assignment_id: 8, student_course_id: 4},
  {assignment_id: 9, student_course_id: 4},
  {assignment_id: 10, student_course_id: 4},
  {assignment_id: 11, student_course_id: 4},
  {assignment_id: 12, student_course_id: 4},
  {assignment_id: 13, student_course_id: 4},
  {assignment_id: 14, student_course_id: 4}
])

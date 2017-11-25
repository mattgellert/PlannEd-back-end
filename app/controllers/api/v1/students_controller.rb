class Api::V1::StudentsController < ApplicationController

  def sign_up #works
    student = Student.create(first_name: params[:firstName], last_name: params[:lastName], email: params[:email])
    self.sign_in
  end

  def sign_in #works
    current_student = Student.find_by(email: params[:email])
    render json: {
      student: {
        id: current_student.id,
        email: current_student.email,
        firstName: current_student.first_name,
        lastName: current_student.last_name
      }
    }
  end

  def add_student_course # works
    student = Student.find(params[:student][:id])
    course = Course.find_or_create_by({
      crse_id: params[:studentCourse][:crseId],
      subject: params[:studentCourse][:subject],
      catalog_nbr: params[:studentCourse][:catalogNbr],
      title: params[:studentCourse][:title],
      description: params[:studentCourse][:description],
      units_minimum: params[:studentCourse][:unitsMinimum],
      units_maximum: params[:studentCourse][:unitsMaximum],
      session_begin_dt: params[:studentCourse][:sessionBeginDt],
      session_end_dt: params[:studentCourse][:sessionEndDt]
    })
    student_course = StudentCourse.create({
      student_id: student.id,
      course_id: course.id,
      section: params[:studentCourse][:section],
      time_start: params[:studentCourse][:timeStart],
      time_end: params[:studentCourse][:timeEnd],
      pattern: params[:studentCourse][:pattern],
      facility_descr: params[:studentCourse][:facilityDescr],
      facility_descr_short: params[:studentCourse][:facilityDescrShort]
    })
    instructors = params[:instructors] #will this be returned in the right format?
    instructors.each do |instructor|
      inst = Instructor.find_or_create_by({
        net_id: instructor[:netId],
        first_name: instructor[:firstName],
        last_name: instructor[:lastName]
      })
      StudentCourseInstructor.create({
        student_course_id: student_course.id,
        instructor_id: inst.id
      })
    end

    if course.assignments.length == 0
      self.create_mock_data(course, student, student_course) ###UPDATE LATER WITH BETTER DATA
    end
    student_course.parent.assignments.each do |assignment|
      StudentAssignment.create({
          assignment_id: assignment.id,
          student_course_id: student_course.id
      })
    end
    # add other data for calendar later
    render json: {
      studentCourse: {
        crseId: course.crse_id,
        subject: course.subject,
        catalogNbr: course.catalog_nbr,
        title: course.title,
        description: course.description,
        unitsMinimum: course.units_minimum,
        unitsMaximum: course.units_maximum,
        sessionBeginDt: course.session_begin_dt,
        sessionEndDt: course.session_end_dt
      },
      studentAssignments: self.student_assignments(true)
    }
  end

  def student_assignments(helper = false) # works
    student_assignments = []
    if helper
      student_courses = StudentCourse.all.where(student_id: params[:student][:id])
      student_courses.each do |student_course|
        student_course.student_assignments.each do |student_assignment|
          student_assignments.push(student_assignment)
        end
      end
      return self.format_assignments(student_assignments)
    else
      student_courses = StudentCourse.all.where(student_id: params[:studentId])
      student_courses.each do |student_course|
        student_assignments.push(self.format_assignments(student_course.student_assignments))
      end
      render json: { studentAssignments: student_assignments.flatten }
    end
  end

  def student_courses
    student_courses = StudentCourse.all.where(student_id: params[:studentId])
    formatted_student_courses = []
    student_courses.each do |student_course|
      formatted_student_courses.push({
          studentCourseId: student_course.id,
          section: student_course.section,
          title: student_course.parent.title,
          timeStart: student_course.time_start,
          timeEnd: student_course.time_end,
          pattern: student_course.pattern,
          completed: student_course.completed,
          facilityDescr: student_course.facility_descr,
          facilityDescrShort: student_course.facility_descr_short,
          subject: student_course.parent.subject,
          catalogNbr: student_course.parent.catalog_nbr,
          description: student_course.parent.description
      })
    end
    render json: { studentCourses: formatted_student_courses }
  end

  def complete_assignment
    student_assignment = StudentAssignment.find(params[:studentAssignmentId])
    student_assignment.completed = true
    render json: { studentAssignment: self.format_assignments([student_assignment])[0] }
  end

  def complete_course
    student_course = StudentCourse.find(params[:studentCourseId])
    student_course.completed = true
    render json: {
      studentCourse: {
        studentCourseId: student_course.id,
        section: student_course.section,
        title: student_course.parent.title,
        timeStart: student_course.time_start,
        timeEnd: student_course.time_end,
        pattern: student_course.pattern,
        completed: student_course.completed,
        facilityDescr: student_course.facility_descr,
        facilityDescrShort: student_course.facility_descr_short,
        subject: student_course.parent.subject,
        catalogNbr: student_course.parent.catalog_nbr,
        description: student_course.parent.description
      }
    }
  end

  def get_sub_assignments # works
    student_assignment = StudentAssignment.find(params[:studentAssignmentId])
    student_sub_assignments = []
    student_assignment.parent.sub_assignments.each do |sub_assignment|
      student_sub_assignments.push(StudentAssignment.find_by(assignment_id: sub_assignment.id, student_course_id: student_assignment.student_course_id))
    end
    render json: {
      parentAssignmentId: params[:studentAssignmentId],
      subAssignments: self.format_assignments(student_sub_assignments)
    }
  end

  def format_assignments(student_assignments) # works
    formatted_assignments = []
    assignments_seen = {}
    student_assignments.each do |student_assignment|
        if StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id) && assignments_seen["#{StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id).id}"]
          return formatted_assignments
        else
          formatted_assignments.push({
            studentAssignmentId: student_assignment.id,
            studentCourseId: student_assignment.student_course.id,
            title: student_assignment.parent.title,
            description: student_assignment.parent.description,
            dueDate: student_assignment.parent.due_date,
            completed: student_assignment.completed,
            subAssignments: [],
            hasSubAssignments: student_assignment.parent.sub_assignments.length > 0 ? true : false,
            parentStudentAssignmentId: StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id) ? StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id).id : nil
          })
          assignments_seen["#{student_assignment.id}"] = true
        end
    end
    return formatted_assignments
  end

  def create_mock_data(course, student, student_course) # works
    20.times do |i|
      date = DateTime.new(2017,9,i + 1,5)
      pri = Assignment.create({course_id: course.id, title: "#{course.title} assignment #{i}", description: "complete assignment ##{i}", due_date: date})
      StudentAssignment.create({assignment_id: pri.id, student_course_id: student_course.id})
      if i % 2 == 0
        sub1a = Assignment.create({course_id: course.id, title: "#{course.title} assignment #{i}a", description: "complete assignment ##{i}a", due_date: date - 1, primary_assignment_id: pri.id})
        StudentAssignment.create({assignment_id: sub1a.id, student_course_id: student_course.id})
      end
      if i % 4 == 0
        sub1a_ = Assignment.create({course_id: course.id, title: "#{course.title} assignment #{i}a_1", description: "complete assignment ##{i}a_1", due_date: date - 2, primary_assignment_id: sub1.id})
        StudentAssignment.create({assignment_id: sub1a_1.id, student_course_id: student_course.id})
      end
    end
  end


end

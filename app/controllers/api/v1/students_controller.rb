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
    components = []
    params[:studentCourse][:components].each do |component|
      student_course_comp = StudentCourseComponent.create({
        student_course_id: student_course.id,
        title: component[:title],
        component: component[:component],
        section: component[:section],
        time_start: component[:timeStart],
        time_end: component[:timeEnd],
        pattern: component[:pattern],
        facility_descr: component[:facilityDescr],
        facility_descr_short: component[:facilityDescrShort]
      })
      components.push(student_course_comp)
    end

    formatted_components = self.format_components(components)

    instructors = params[:instructors] #will this be returned in the right format?
    instructors.each do |instructor|
      inst = Instructor.find_or_create_by({
        net_id: instructor[:netid],
        first_name: instructor[:firstName],
        last_name: instructor[:lastName]
      })
      StudentCourseInstructor.create({
        student_course_id: student_course.id,
        instructor_id: inst.id
      })
    end

    if course.assignments.length == 0
      student_assignments = self.create_mock_data(course, student, student_course) ###UPDATE LATER WITH BETTER DATA
    else
      student_assignments = self.add_student_assignments(course, student_course)
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
        description: student_course.parent.description,
        components: formatted_components
      },
      studentAssignments: self.format_assignments(student_assignments)
    }
  end

  def format_components(components)
    formatted_components = []
    components.each do |component|
      formatted_components.push({
        studentComponentId: component.id,
        studentCourseId: component.student_course_id,
        title: component.title,
        component: component.component,
        section: component.section,
        timeStart: component.time_start,
        timeEnd: component.time_end,
        pattern: component.pattern,
        facilityDescr: component.facility_descr,
        facilityDescrShort: component.facility_descr_short
      })
    end
    return formatted_components
  end

  def student_assignments # works
    student_assignments = []
      student_courses = StudentCourse.all.where(student_id: params[:studentId])
      student_courses.each do |student_course|
        student_assignments.push(self.format_assignments(student_course.student_assignments))
      end
      render json: { studentAssignments: student_assignments.flatten }
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
          description: student_course.parent.description,
          components: self.format_components(student_course.student_course_components)
      })
    end
    render json: { studentCourses: formatted_student_courses }
  end

  def complete_assignment
    student_assignment = StudentAssignment.find(params[:studentAssignmentId])
    student_assignment.completed = !student_assignment.completed
    student_assignment.save
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
        if student_assignment.parent.primary_assignment_id && assignments_seen["#{student_assignment.parent.primary_assignment_id}"]
          byebug
          assignments_seen["#{student_assignment.id}"] = true
          # do nothing
        else
          byebug
          obj = {
            studentAssignmentId: student_assignment.id,
            studentCourseId: student_assignment.student_course.id,
            title: student_assignment.parent.title,
            description: student_assignment.parent.description,
            dueDate: student_assignment.parent.due_date,
            completed: student_assignment.completed,
            subAssignments: [],
            hasSubAssignments: student_assignment.parent.sub_assignments.length > 0 ? true : false,
            parentStudentAssignmentId: StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id) ? StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id).id : nil
          }
          formatted_assignments.push(obj)
          assignments_seen["#{student_assignment.id}"] = true
        end
    end
    # not hitting this on add new course then push to assignments page
    return formatted_assignments
  end

  def create_mock_data(course, student, student_course) # works
    student_assignments = []
    10.times do |i|
      date = DateTime.new(2017,12,i + 1,5)
      pri = Assignment.create({course_id: course.id, title: "#{course.title} assignment #{i+1}", description: "complete assignment ##{i+1}", due_date: date})
      student_assignments.push(StudentAssignment.create({assignment_id: pri.id, student_course_id: student_course.id}))
      if i % 2 == 0
        sub1a = Assignment.create({course_id: course.id, title: "#{course.title} assignment #{i+1}a", description: "complete assignment ##{i+1}a", due_date: date - 1, primary_assignment_id: pri.id})
        student_assignments.push(StudentAssignment.create({assignment_id: sub1a.id, student_course_id: student_course.id}))
      end
      if i % 4 == 0
        sub1a_a = Assignment.create({course_id: course.id, title: "#{course.title} assignment #{i+1}a_a", description: "complete assignment ##{i+1}a_a", due_date: date - 2, primary_assignment_id: sub1a.id})
        student_assignments.push(StudentAssignment.create({assignment_id: sub1a_a.id, student_course_id: student_course.id}))
      end
    end
    byebug
    return student_assignments
  end

  def add_student_assignments(course, student_course)
    student_assignments = []
      course.assignments.each do |assignment|
        student_assignments.push(StudentAssignment.create({assignment_id: assignment.id, student_course_id: student_course.id}))
      end
    return student_assignments
  end


end

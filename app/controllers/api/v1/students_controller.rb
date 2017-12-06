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

  def time_string_to_num(time)
    num = time.scan(/\d+|\D+/)
    num.delete_at(1)
    num[0] = num[2] == "PM" ? (num[0].to_i + 12).to_s : num[0]
    num.delete_at(2)
    return num.join(".").to_f
  end

  def check_for_course_conflicts(student)
    # get pattern & timeStart/timeEnd of new course
    new_pattern = params[:studentCourse][:pattern]
    new_start = self.time_string_to_num(params[:studentCourse][:timeStart])
    new_end = self.time_string_to_num(params[:studentCourse][:timeEnd])

    # get pattern & timeStart/timeEnd of all courses & components
    student_courses = StudentCourse.all.where(student_id: student.id)
    time_slots = []
    student_courses.each do |course|
      if course.student_course_components.length > 0
        course_and_comps = [{
          title_short: "#{course.parent.subject} #{course.parent.catalog_nbr}",
          pattern: course.pattern,
          time_start: self.time_string_to_num(course.time_start),
          time_end: self.time_string_to_num(course.time_end),
        }]
        course.student_course_components.each do |comp|
          course_and_comps.push({
            title_short: "#{comp.course_parent.subject} #{comp.course_parent.catalog_nbr}",
            pattern: comp.pattern,
            time_start: self.time_string_to_num(comp.time_start),
            time_end: self.time_string_to_num(comp.time_end),
          })
        end
        time_slots.push(course_and_comps)
      else
        time_slots.push({
          title_short: "#{course.parent.subject} #{course.parent.catalog_nbr}",
          pattern: course.pattern,
          time_start: self.time_string_to_num(course.time_start),
          time_end: self.time_string_to_num(course.time_end),
        })
      end
    end

    #check for conflicts with each time slot
    conflicts = []
    time_slots.flatten.each do |slot|
      if ((new_start > slot[:time_start]) && (new_start < slot[:time_end])) || ((new_end > slot[:time_start]) && (new_end < slot[:time_end]))
        conflicts.push(slot[:title_short])
      end
    end
    return conflicts
  end

  def convert_date_to_array(date)
    return [date.year, date.month - 1, date.day, date.hour, date.min]
  end

  def create_student_course_events(student_course, comp = false)
    if !comp
      parent = student_course.parent
      session_begin = parent.session_begin_dt.split("/").map {|t| t.to_i }
      session_end = parent.session_end_dt.split("/").map {|t| t.to_i }
    else
      session_begin = student_course.course_parent.session_begin_dt.split("/").map {|t| t.to_i }
      session_end = student_course.course_parent.session_end_dt.split("/").map {|t| t.to_i }
    end

    beginDt = DateTime.new(session_begin[2], session_begin[0], session_begin[1])
    endDt = DateTime.new(session_end[2], session_end[0], session_end[1])

    timeStart = student_course.time_start
    timeStart = timeStart.scan(/\d+|\D+/)
    timeStart.delete_at(1)
    timeStart[0] = (timeStart[2] == "PM" && timeStart[0] != "12") ? (timeStart[0].to_i + 12).to_s : timeStart[0]
    timeStart.delete_at(2)


    timeEnd = student_course.time_end
    timeEnd = timeEnd.scan(/\d+|\D+/)
    timeEnd.delete_at(1)
    timeEnd[0] = (timeEnd[2] == "PM" && timeEnd[0] != "12") ? (timeEnd[0].to_i + 12).to_s : timeEnd[0]
    timeEnd.delete_at(2)

    startDates = student_course.pattern.split("").map do |day|
      bgnDt = beginDt
      case day
      when "M"
        num = 0
      when "T"
        num = 1
      when "W"
        num = 2
      when "R"
        num = 3
      when "F"
        num = 4
      else
        break
      end
      bgnDt = bgnDt.next_week.advance(:days=>num)
      bgnDt = bgnDt.change({ hour: timeStart[0].to_i, min: timeStart[1].to_i })
    end

    startDates.each do |start|
      max = (endDt - start).floor
      count = 1
      while count < (max/7 + 1) do
        courseDt = start + (count * 7)

        courseDtEnd = courseDt.change({ hour: timeEnd[0].to_i, min: timeEnd[1].to_i })
        if !comp
          event = Event.create({
            title: "#{parent.subject} #{parent.catalog_nbr}",
            start_date: courseDt,
            end_date: courseDtEnd,
            color: student_course.color,
            student_course_id: student_course.id
          })
          StudentCourseEvent.create({
            event_id: event.id,
            student_course_id: student_course.id
          })
        else
          event = Event.create({
            title: "#{student_course.component} #{student_course.course_parent.subject} #{student_course.course_parent.catalog_nbr}",
            start_date: courseDt,
            end_date: courseDtEnd,
            color: student_course.color,
            student_course_id: student_course.id
          })
          StudCourseCompEvent.create({
            event_id: event.id,
            student_course_component_id: student_course.id
          })
        end
        count += 1
      end
    end
  end

  def create_due_dates(studentId)
    due_dates = []
    StudentCourse.all.where(student_id: studentId).each do |course|
      course.student_assignments.each do |assignment|
        event = Event.create({
          title: "DUE #{assignment.parent.title}",
          due_date: true,
          start_date: assignment.parent.due_date,
          end_date: assignment.parent.due_date,
          color: course.color,
          student_course_id: course.id,
          student_assignment_id: assignment.id
        })
        StudentAssignmentEvent.create({
          event_id: event.id,
          student_assignment_id: assignment.id,
        })
        this_event = {
          "id": event.id,
          "title": "DUE #{assignment.parent.title}",
          "eventType": "due date",
          "startDate": self.convert_date_to_array(assignment.parent.due_date),
          "endDate": self.convert_date_to_array(assignment.parent.due_date),
          "color": event.color,
          "studentCourseId": event.student_course_id,
          "studentAssignmentId": assignment.id,
          "completed": assignment.completed
        }
        due_dates.push(this_event)
      end
    end
    return due_dates
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

    conflicts = self.check_for_course_conflicts(student)
    if conflicts.length > 0
      render json: { error: "This conflicts with: #{conflicts.join(',')}" }
    else
      student_course = StudentCourse.create({
        student_id: student.id,
        course_id: course.id,
        section: params[:studentCourse][:section],
        time_start: params[:studentCourse][:timeStart],
        time_end: params[:studentCourse][:timeEnd],
        pattern: params[:studentCourse][:pattern],
        facility_descr: params[:studentCourse][:facilityDescr],
        facility_descr_short: params[:studentCourse][:facilityDescrShort],
        color: params[:color]
        })
        ##################
        self.create_student_course_events(student_course)
        student_course_events = student_course.events.map do |event|
          this_event = {
            'id': event.id,
            'title': event.title,
            'eventType': "course",
            'startDate': self.convert_date_to_array(event.start_date),
            'endDate': self.convert_date_to_array(event.end_date),
            'color': params[:color],
            'studentCourseId': event.student_course_id
          }
        end

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
            facility_descr_short: component[:facilityDescrShort],
            color: params[:color]
          })
          ##################
          self.create_student_course_events(student_course_comp, true)
          component_events = student_course_comp.events.map do |event|
            this_event = {
              'id': event.id,
              'title': event.title,
              'eventType': "course",
              'startDate': self.convert_date_to_array(event.start_date),
              'endDate': self.convert_date_to_array(event.end_date),
              'color': event.color,
              'studentCourseId': event.student_course_id
            }
          end
          student_course_events.push(component_events)
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

        ##################
        # new_due_dates = self.create_due_dates(student.id)
        new_due_dates = self.create_due_dates(student.id)

        # add other assignment data for calendar later
        render json: {
          studentCourse: {
            studentCourseId: student_course.id,
            crseId: course.crse_id,
            section: student_course.section,
            title: student_course.parent.title,
            sessionBeginDt: student_course.parent.session_begin_dt,
            sessionEndDt: student_course.parent.session_end_dt,
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
          studentAssignments: self.format_assignments(student_assignments),
          dueDates: new_due_dates,
          courseDates: student_course_events.flatten
        }
    end
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
    student_course_dates = []
    student_assignments = []
    unformatted_assignments = []
    student_courses = StudentCourse.all.where(student_id: params[:studentId])
    student_courses.each do |student_course|
      assignments = student_course.student_assignments
      unformatted_assignments.push(assignments)
      student_assignments.push(self.format_assignments(assignments))
      student_course_dates.push(student_course.events)
      component_events = student_course.student_course_components.map do |comp|
        comp.events
      end
      student_course_dates.push(component_events.flatten)
    end

    student_course_dates = student_course_dates.flatten.map do |event|
      this_event = {
        'id': event.id,
        'title': event.title,
        'eventType': "course",
        "startDate": self.convert_date_to_array(event.start_date),
        "endDate": self.convert_date_to_array(event.end_date),
        'color': event.color,
        'studentCourseId': event.student_course_id
      }
    end

    student_due_dates = unformatted_assignments.flatten.map do |assignment|
      event = assignment.events.where(due_date: true)[0]
      this_event = {
        'id': event.id,
        'title': event.title,
        'eventType': "due date",
        "startDate": self.convert_date_to_array(event.start_date),
        "endDate": self.convert_date_to_array(event.end_date),
        'color': event.color,
        'studentCourseId': event.student_course_id,
        'studentAssignmentId': assignment.id,
        'completed': assignment.completed
      }
    end

    student_assignment_to_dos = unformatted_assignments.flatten.map do |assignment|
      events = assignment.events.where(assignment_to_do: true)
      events.map do |event|
        this_event = {
          'id': event.id,
          'title': event.title,
          'description': event.description,
          'eventType': "to do",
          "startDate": self.convert_date_to_array(event.start_date),
          "endDate": self.convert_date_to_array(event.end_date),
          'color': event.color,
          'studentCourseId': event.student_course_id,
          'studentAssignmentId': assignment.id,
          'completed': assignment.completed
        }
      end
    end

    render json: { studentAssignments: student_assignments.flatten, dueDates: student_due_dates, courseDates: student_course_dates, toDoItems: student_assignment_to_dos.flatten }
  end

  def is_completed_parent(student_assignment, numSubs)
    student_assignment.parent.sub_assignments.each_with_index do |sub_ass, idx| #is from the class Assignment so need the Student's verions -->
      student_sub_ass = StudentAssignment.find_by(assignment_id: sub_ass.id, student_course_id: student_assignment.student_course_id)
      if !self.is_completed_parent(student_sub_ass, 0)
        return false
      end
      if (idx + 1) == numSubs
        return true
      end
    end
    return (!student_assignment.completed) ? false : true
  end

  def format_assignments(student_assignments) # works
    formatted_assignments = []
    assignments_seen = {}
    completed = false
    course = Course.find(StudentAssignment.find(student_assignments[0].id).parent.course_id)
    subject = course.subject
    catalog_nbr = course.catalog_nbr
    student_assignments.each do |student_assignment|
      if student_assignment.parent.sub_assignments.length > 0
        completed = self.is_completed_parent(student_assignment, student_assignment.parent.sub_assignments.length)
      else
        completed = student_assignment.completed
      end
      if completed != student_assignment.completed
        student_assignment.completed = completed
        student_assignment.save
      end
      if !!student_assignment.parent.primary_assignment_id && assignments_seen["#{student_assignment.parent.primary_assignment_id}"]
        assignments_seen["#{student_assignment.parent.id}"] = true
      else
        obj = {
          studentAssignmentId: student_assignment.id,
          studentCourseId: student_assignment.student_course.id,
          subject: subject,
          catalogNbr: catalog_nbr,
          courseTitle: course.title,
          title: student_assignment.parent.title,
          description: student_assignment.parent.description,
          dueDate: student_assignment.parent.due_date,
          completed: student_assignment.completed,
          subAssignments: [],
          hasSubAssignments: student_assignment.parent.sub_assignments.length > 0 ? true : false,
          selectedNow: false,
          parentStudentAssignmentId: StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id) ? StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id).id : nil
        }
        formatted_assignments.push(obj)
        assignments_seen["#{student_assignment.parent.id}"] = true
      end
    end
    return formatted_assignments
  end

  def format_assignments_without_filter(student_assignments)
    formatted_assignments = []
    completed = false
    course = Course.find(StudentAssignment.find(student_assignments[0].id).parent.course_id)
    subject = course.subject
    catalog_nbr = course.catalog_nbr
    student_assignments.each do |student_assignment|
      if student_assignment.parent.sub_assignments.length > 0
        completed = self.is_completed_parent(student_assignment, student_assignment.parent.sub_assignments.length)
      else
        completed = student_assignment.completed
      end
      if completed != student_assignment.completed
        student_assignment.completed = completed
        student_assignment.save
      end
        obj = {
          studentAssignmentId: student_assignment.id,
          studentCourseId: student_assignment.student_course.id,
          subject: subject,
          catalogNbr: catalog_nbr,
          courseTitle: course.title,
          title: student_assignment.parent.title,
          description: student_assignment.parent.description,
          dueDate: student_assignment.parent.due_date,
          completed: student_assignment.completed,
          subAssignments: [],
          hasSubAssignments: student_assignment.parent.sub_assignments.length > 0 ? true : false,
          selectedNow: false,
          parentStudentAssignmentId: StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id) ? StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id).id : nil
        }
        formatted_assignments.push(obj)
    end
    return formatted_assignments
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
          color: student_course.color,
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
    if params[:isSubAssignment]
      root_assignments = params[:rootAssignmentIds].map { |id| StudentAssignment.find(id) }
      sub_assignments = params[:subAssignmentIds].map { |id| StudentAssignment.find(id) }
      sub_assignments.push(student_assignment)
      ids = params[:rootAssignmentIds].concat(params[:subAssignmentIds])
      all_assignments = [root_assignments, sub_assignments].flatten
      updated_due_date_events = self.update_due_dates_on_complete(all_assignments)
      toDos = self.update_to_do_on_complete(all_assignments)
      render json: {
        ids: ids,
        subAssignments: self.format_assignments_without_filter(sub_assignments),
        rootAssignments: self.format_assignments(root_assignments),
        dueDates: updated_due_date_events,
        toDos: toDos
      }
    else
      updated_due_date_events = self.update_due_dates_on_complete([student_assignment])
      toDos = self.update_to_do_on_complete([student_assignment])
      render json: {
        studentAssignment: self.format_assignments([student_assignment])[0],
        dueDates: updated_due_date_events,
        toDos: toDos
      }
    end
  end

  def update_due_dates_on_complete(student_assignments)
    updated_event_ids = student_assignments.map do |assignment|
      events = assignment.events.where(due_date: true).map do |event|
        # event.completed = !event.completed
        # event.save
        this_event_id = event.id
      end
    end
    return updated_event_ids.flatten
  end

  def update_to_do_on_complete(student_assignments)
    updated_event_ids = student_assignments.map do |assignment|
      events = assignment.events.where(assignment_to_do: true).map do |event|
        # event.completed = !event.completed
        # event.save
        this_event_id = event.id
      end
    end
    return updated_event_ids.flatten
  end

  def complete_parent_assignment
    parent_assignment = StudentAssignment.find(params[:studentAssignmentId])
    @@ids = [parent_assignment.id]
    @@all_assignments = [parent_assignment]
    parent_assignment.completed = !parent_assignment.completed
    parent_assignment.save
    if parent_assignment.completed
      self.complete_children(parent_assignment)
      toDos = self.update_to_do_on_complete([parent_assignment])
      render json: { ids: @@ids, completed: true, dueDates: self.update_due_dates_on_complete(@@all_assignments), toDos: toDos }
    else
      self.incomplete_children(parent_assignment)
      toDos = self.update_to_do_on_complete([parent_assignment])
      render json: { ids: @@ids, completed: false, dueDates: self.update_due_dates_on_complete(@@all_assignments), toDos: toDos }
    end

  end

  def complete_children(student_assignment)
    student_assignment.parent.sub_assignments.each_with_index do |sub_ass, idx| #is from the class Assignment so need the Student's verions -->
      student_sub_ass = StudentAssignment.find_by(assignment_id: sub_ass.id, student_course_id: student_assignment.student_course_id)
      @@ids.push(student_sub_ass.id)
      @@all_assignments.push(student_sub_ass)
      student_sub_ass.completed = true
      student_sub_ass.save
      self.complete_children(student_sub_ass)
    end
  end

  def incomplete_children(student_assignment)
    student_assignment.parent.sub_assignments.each_with_index do |sub_ass, idx| #is from the class Assignment so need the Student's verions -->
      student_sub_ass = StudentAssignment.find_by(assignment_id: sub_ass.id, student_course_id: student_assignment.student_course_id)
      @@ids.push(student_sub_ass.id)
      @@all_assignments.push(student_sub_ass)
      student_sub_ass.completed = false
      student_sub_ass.save
      self.complete_children(student_sub_ass)
    end
  end

  # def delete_to_do_on_complete
  #   if params[:keep]
  #     updated_to_dos =
  #   else
  #     updated_to_dos =
  #   end
  #   render json: { toDos: updated_to_dos }
  #   # depending on user input, delete to do items of completed shit or dont and return them
  #
  # end

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
      subAssignments: self.format_assignments(student_sub_assignments),
      hasParent: student_assignment.parent.primary_assignment_id,
    }
  end


  def create_mock_data(course, student, student_course)
    student_assignments = []

    parent = student_course.parent
    session_begin = parent.session_begin_dt.split("/").map {|t| t.to_i }
    session_end = parent.session_end_dt.split("/").map {|t| t.to_i }

    beginDt = DateTime.new(session_begin[2], session_begin[0], session_begin[1])
    currDt = beginDt.next_week.advance(:days=>4).change({ hour: (rand(8) + 10) })
    endDt = DateTime.new(session_end[2], session_end[0], session_end[1])
    i = 0

    while currDt < endDt do
      pri = Assignment.create({course_id: course.id, title: "Assignment #{i+1}", description: "This is assignment #{i+1} for #{course.title}. The objective of this assignment is to complete assignment ##{i+1}. Please complete it by the given due date.", due_date: currDt})
      student_assignments.push(StudentAssignment.create({assignment_id: pri.id, student_course_id: student_course.id}))
      if (i+1) % 4 == 0
        sub1a = Assignment.create({course_id: course.id, title: "Assignment #{i+1}a", description: "This is assignment #{i+1}a for #{course.title}. The objective of this assignment is to complete assignment ##{i+1}. Please complete it by the given due date.", due_date: currDt - 2, primary_assignment_id: pri.id})
        student_assignments.push(StudentAssignment.create({assignment_id: sub1a.id, student_course_id: student_course.id}))
      end
      if (i+1) % 8 == 0
        sub1a_a = Assignment.create({course_id: course.id, title: "Assignment #{i+1}a_a", description: "This is assignment #{i+1} for #{course.title}. The objective of this assignment is to complete assignment ##{i+1}a_a. Please complete it by the given due date.", due_date: currDt - 3, primary_assignment_id: sub1a.id})
        student_assignments.push(StudentAssignment.create({assignment_id: sub1a_a.id, student_course_id: student_course.id}))
        sub1a_b = Assignment.create({course_id: course.id, title: "Assignment #{i+1}b_a", description: "This is assignment #{i+1} for #{course.title}. The objective of this assignment is to complete assignment ##{i+1}a_b. Please complete it by the given due date.", due_date: currDt - 2, primary_assignment_id: sub1a.id})
        student_assignments.push(StudentAssignment.create({assignment_id: sub1a_b.id, student_course_id: student_course.id}))
      end
      currDt = currDt.next_week.advance(:days=>rand(5)).change({ hour: (rand(8) + 10) })
      i += 1
    end
    return student_assignments
  end

  def add_student_assignments(course, student_course)
    student_assignments = course.assignments.map do |assignment|
      StudentAssignment.create({assignment_id: assignment.id, student_course_id: student_course.id})
    end
  end

  def add_assignment_to_do
    date = params[:date].split("/").map {|t| t.to_i }
    time = params[:time].split(":").map {|t| t.to_i }
    student_assignment = StudentAssignment.find(params[:studentAssignmentId])
    student_course = StudentCourse.find(student_assignment.student_course_id)
    event = Event.create({
      title: params[:title],
      assignment_to_do: true,
      description: params[:description],
      start_date: DateTime.new(date[2], date[0], date[1]).change({ hour: time[0], min: time[1] }),
      end_date: DateTime.new(date[2], date[0], date[1]).change({ hour: time[2], min: time[3] }),
      color: student_course.color,
      student_course_id: student_course.id,
      student_assignment_id: params[:studentAssignmentId]
    })
    StudentAssignmentEvent.create({
      event_id: event.id,
      student_assignment_id: params[:studentAssignmentId]
    })

    render json: {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'eventType': "to do",
      "startDate": self.convert_date_to_array(event.start_date),
      "endDate": self.convert_date_to_array(event.end_date),
      'color': event.color,
      'studentCourseId': event.student_course_id,
      'studentAssignmentId': student_assignment.id,
      'completed': student_assignment.completed
    }
  end

  def remove_course
    student_course = StudentCourse.find(params[:studentCourseId])
    student_id = student_course.student_id
    starting_courses = StudentCourse.all.where(student_id: student_id)

    #destroy all join table
    student_course_instructors = StudentCourseInstructor.all.where(student_course_id: student_course.id).each{|i| i.delete }

    student_course_components = StudentCourseComponent.all.where(student_course_id: student_course.id)
    student_course_components.each do |comp|
      StudCourseCompEvent.all.where(student_course_component_id: comp.id).each{|c| c.delete}
      comp.delete
    end
    StudentCourseEvent.all.where(student_course_id: student_course.id).each{|e| e.delete }
    student_course_events = student_course.events.each{|e| e.delete }
    student_assignment_events = student_course.student_assignments.each do |ass|
      StudentAssignmentEvent.all.where(student_assignment_id: ass.id).each{|a| a.delete }
      ass.events.each{|e| e.delete }
      ass.delete
    end

    student_course.delete

    remaining_courses = StudentCourse.all.where(student_id: student_id)
    params[:studentId] = student_id
    self.student_courses
  end

  def update_course_color
    student_course = StudentCourse.find(params[:studentCourseId])
    student_id = student_course.student_id
    color = params[:color]
    student_course.color = color
    student_course.save

    student_course.student_course_components.each do |comp|
      comp.color = color
      comp.save
      comp.events.each do |event|
        event.color = color
        event.save
      end
    end

    student_course.events.each do |event|
      event.color = color
      event.save
    end

    student_course.student_assignments.each do |assignment|
      assignment.events.each do |event|
        event.color = color
        event.save
      end
    end
    params[:studentId] = student_id
    self.student_courses
  end

end

# studentAssignmentId: student_assignment.id,
# studentCourseId: student_assignment.student_course.id,
# title: student_assignment.parent.title,
# description: student_assignment.parent.description,
# dueDate: student_assignment.parent.due_date,
# completed: student_assignment.completed,
# subAssignments: [],
# hasSubAssignments: student_assignment.parent.sub_assignments.length > 0 ? true : false,
# selectedNow: false,
# parentStudentAssignmentId: StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id) ? StudentAssignment.find_by(assignment_id: student_assignment.parent.primary_assignment_id, student_course_id: student_assignment.student_course_id).id : nil

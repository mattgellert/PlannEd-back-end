Rails.application.routes.draw do
  resources :student_course_component_events
  resources :student_assignment_events
  resources :student_assignment_due_dates
  resources :student_course_events
  resources :events
  resources :student_course_components
  resources :student_course_instructors
  resources :instructors
  namespace :api do
    namespace :v1 do
      # students
      post '/students/sign_up', to: 'students#sign_up'
      post '/students/sign_in', to: 'students#sign_in'
      post '/students/add_student_course', to: 'students#add_student_course'
      get '/students/student_assignments', to: 'students#student_assignments'
      get '/students/student_courses', to: 'students#student_courses'
      post '/students/complete_assignment', to: 'students#complete_assignment'
      post '/students/complete_parent_assignment', to: 'students#complete_parent_assignment'
      post '/students/complete_course', to: 'students#complete_course'
      get '/students/get_sub_assignments', to: 'students#get_sub_assignments'
      # get '/students/upcoming', to: 'students#upcoming_assignments'
    end
  end
end

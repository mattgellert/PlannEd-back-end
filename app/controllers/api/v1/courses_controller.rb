class Api::V1::CoursesController < ApplicationController

  def index
    courses = Course.all
    render json: { courses: courses }
  end

end

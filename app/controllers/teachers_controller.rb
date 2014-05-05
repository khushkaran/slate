class TeachersController < ApplicationController
  before_action :authenticate_teacher!, only: [:dashboard, :update, :students, :edit_student]

  def dashboard
    @requests = Request.all
    @teacher, @cohorts, @cohort_options = current_teacher, cohorts_in_order, cohort_options
    @cohort = Cohort.find(selected_cohort) if selected_cohort
    @students = Student.where(cohort: selected_cohort, approved: true)    
  end

  def update
    teacher = current_teacher
    teacher.cohort = Cohort.find params[:cohort][:id]
    if teacher.save
      flash[:success] = "Default cohort updated successfully"
      redirect_to cohorts_path
    else
      teacher.errors.full_messages.each{ |msg| flash[:error] = msg }
      redirect_to dashboard_teachers_path
    end
  end

  def students
    @approved = Student.where(approved: true)
    @unapproved = Student.where(approved: false)
    params[:approved] ? (@students, @switch = @approved, "Unapprove") : (@students, @switch = @unapproved, "Approve")
  end

  def edit_student
    @student = Student.find params[:id]
    @cohort_options = cohort_options
  end

  private
  def selected_cohort
    params[:cohort] || @teacher.cohort
  end
end

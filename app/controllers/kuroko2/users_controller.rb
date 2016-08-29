class UsersController < ApplicationController
  before_action :set_user, only: [:destroy]

  def index
    @user  = User.new
    if params[:target] == 'group'
      @users = User.group_user.all.page(page_params[:page])
    else
      @users = User.all.page(page_params[:page])
    end
  end

  def show
    @user = User.find(params[:id])
    @input_tags  = params[:tag] || []

    @definitions = @user.assigned_job_definitions
    if @input_tags.present?
      @definitions = @definitions.tagged_by(@input_tags)
    end

    @instances    = JobInstance.working.where(job_definition: @definitions)
    @related_tags = @definitions.includes(:tags).map(&:tags).flatten.uniq
  end

  def create
    @user = User.new(user_params)
    @user.provider = User::GROUP_PROVIDER
    @user.uid      = @user.email

    if @user.save
      redirect_to users_path
    else
      @users = User.all

      render action: :index
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_url
    else
      @users = User.all

      render :index
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def page_params
    params.permit(:page)
  end
end

class Kuroko2::UsersController < Kuroko2::ApplicationController
  before_action :set_user, only: [:destroy]

  def index
    @user  = Kuroko2::User.new
    if params[:target] == 'group'
      @users = Kuroko2::User.group_user.all.page(page_params[:page])
    else
      @users = Kuroko2::User.all.page(page_params[:page])
    end
  end

  def show
    @user = Kuroko2::User.find(params[:id])
    @input_tags  = params[:tag] || []

    @definitions = @user.assigned_job_definitions
    if @input_tags.present?
      @definitions = @definitions.tagged_by(@input_tags)
    end

    @instances    = Kuroko2::JobInstance.working.where(job_definition: @definitions)
    @related_tags = @definitions.includes(:tags).map(&:tags).flatten.uniq
  end

  def create
    @user = Kuroko2::User.new(user_params)
    @user.provider = Kuroko2::User::GROUP_PROVIDER
    @user.uid      = @user.email

    if @user.save
      redirect_to users_path
    else
      @users = Kuroko2::User.all

      render action: :index
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_url
    else
      @users = Kuroko2::User.all

      render :index
    end
  end

  private
  def set_user
    @user = Kuroko2::User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end

  def page_params
    params.permit(:page)
  end
end

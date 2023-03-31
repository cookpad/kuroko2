class Kuroko2::StarsController < Kuroko2::ApplicationController
  def create
    star = Kuroko2::Star.new do |star|
      star.job_definition = Kuroko2::JobDefinition.find(star_params[:job_definition_id])
      star.user           = current_user
    end

    if (star.save)
      render json: star, status: :created
    else
      raise Http::BadRequest
    end
  end

  def destroy
    star = Kuroko2::Star.find(params[:id])

    if (star.destroy)
      render json: star, status: :ok
    else
      raise Http::BadRequest
    end
  end

  private

  def star_params
    params.permit(:job_definition_id)
  end
end

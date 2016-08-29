class StarsController < ApplicationController
  def create
    star = Star.new do |star|
      star.job_definition = JobDefinition.find(star_params[:job_definition_id])
      star.user           = current_user
    end

    if (star.save)
      render json: star, status: :created
    else
      raise HTTP::BadRequest
    end
  end

  def destroy
    star = Star.find(params[:id])

    if (star.destroy)
      render json: star, status: :ok
    else
      raise HTTP::BadRequest
    end
  end

  private

  def star_params
    params.permit(:job_definition_id)
  end
end

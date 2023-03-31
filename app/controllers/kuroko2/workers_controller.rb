class Kuroko2::WorkersController < Kuroko2::ApplicationController
  before_action :set_worker, only: %i(update)

  def index
    @workers = Kuroko2::Worker.ordered.all
  end

  def update
    @worker.update(worker_params)
    redirect_to workers_path
  end

  private

  def set_worker
    @worker = Kuroko2::Worker.find(params[:id])
  end

  def worker_params
    params.permit(:suspended)
  end
end

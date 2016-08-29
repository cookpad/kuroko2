class Kuroko2::WorkersController < Kuroko2::ApplicationController
  def index
    @workers = Worker.ordered.all
  end
end

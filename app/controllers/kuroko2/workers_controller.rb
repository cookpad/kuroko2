class Kuroko2::WorkersController < Kuroko2::ApplicationController
  def index
    @workers = Kuroko2::Worker.ordered.all
  end
end

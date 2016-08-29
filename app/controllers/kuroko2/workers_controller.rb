class WorkersController < ApplicationController
  def index
    @workers = Worker.ordered.all
  end
end

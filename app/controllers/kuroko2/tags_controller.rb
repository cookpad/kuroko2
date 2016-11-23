class Kuroko2::TagsController < Kuroko2::ApplicationController
  def destroy
    tag = Kuroko2::Tag.find(params[:id])
    tag.destroy

    redirect_back(fallback_location: job_definitions_path)
  end
end

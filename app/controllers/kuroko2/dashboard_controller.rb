class Kuroko2::DashboardController < Kuroko2::ApplicationController
  def index
    @definitions = current_user.job_definitions.includes(:tags, :job_schedules)

    @input_tags  = params[:tag] || []
    if @input_tags.present?
      @definitions = @definitions.tagged_by(@input_tags)
    end

    @instances    = Kuroko2::JobInstance.working.where(job_definition: @definitions)
    @related_tags = @definitions.includes(:tags).map(&:tags).flatten.uniq

  end

  def osd
    render xml: <<-XML.strip_heredoc
    <?xml version="1.0" encoding="UTF-8" ?>
    <OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/">
    <ShortName>Kuroko2</ShortName>
    <Description>Search Kuroko2</Description>
    <InputEncoding>UTF-8</InputEncoding>
    <Url type="text/html" method="get" template="#{job_definitions_url}?q={searchTerms}"/>
    <Image width="16" height="16" type="image/x-icon">#{root_url}favicon.ico</Image>
    </OpenSearchDescription>
    XML
  end
end

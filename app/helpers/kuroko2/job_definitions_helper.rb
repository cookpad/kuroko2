module Kuroko2
  module JobDefinitionsHelper
    def first_line(text)
      truncate(text.split("\n").first, length: 140)
    end

    def markdown_format(text)
      pipeline = HTML::Pipeline.new([HTML::Pipeline::MarkdownFilter])
      raw(pipeline.call(text)[:output].to_s)
    end

    def stared_with(definition)
      current_user.stars.find {|star| star.job_definition_id == definition.id }
    end

    def star_link_for(definition)
      if stared_with(definition)
        link_to(
          raw('<i class="fa fa-star"></i>'),
          job_definition_star_path(id: stared_with(definition), job_definition_id: definition),
          remote: true,
          method: :delete,
          class: 'star',
          data: { definition_id: definition.id, star_id: stared_with(definition).id, definitions_path: job_definitions_path }
        )
      else
        link_to(
          raw('<i class="fa fa-star-o"></i>'),
          job_definition_stars_path(definition.id),
          remote: true,
          method: :post,
          class: 'star',
          data: { definition_id: definition.id, definitions_path: job_definitions_path }
        )
      end
    end
  end
end

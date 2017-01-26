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

    def format_kuroko_script(script_text)
      raw(
        script_text.each_line.map { |line|
          formatted_line = ERB::Util.html_escape(line)

          if (matched = Kuroko2::Workflow::ScriptParser::LINE_REGEXP.match(line.chomp))
            case matched[:type]
            when 'wait'
              formatted_line = format_wait_task(line, matched)
            when 'sub_process'
              formatted_line = format_sub_process_task(line, matched)
            end
          end

          formatted_line
        }.join('')
      )
    end

    private

    def format_wait_task(line, matched)
      definition_names = []
      formatted_line = line.gsub(Kuroko2::Workflow::Task::Wait::OPTION_REGEXP) { |option|
        definition = Kuroko2::JobDefinition.find_by(id: $1.to_i)
        if definition.present?
          definition_names << definition.name
          link_to(option, Kuroko2::Engine.routes.url_helpers.job_definition_path(definition.id))
        else
          option
        end
      }.chomp

      formatted_line << " "
      formatted_line << content_tag(:span, "# #{definition_names.join(', ')}", class: 'note')
      formatted_line << "\n"
    end

    def format_sub_process_task(line, matched)
      definition = Kuroko2::JobDefinition.find_by(id: matched[:option].to_i)
      if definition.present?
        formatted_line = link_to(
          line.chomp,
          Kuroko2::Engine.routes.url_helpers.job_definition_path(definition.id),
        )

        formatted_line << " "
        formatted_line << content_tag(:span, "# #{definition.name}", class: 'note')
        formatted_line << "\n"
      else
        ERB::Util.html_escape(line)
      end
    end
  end
end

module Kuroko2
  module JobInstancesHelper
    def labeled_token_status(status)
      modifier = case status
                 when 'working'
                   'primary'
                 when 'finished'
                   'success'
                 when 'waiting'
                   'warning'
                 when 'failure'
                   'danger'
                 when 'critical'
                   'warning'
                 else
                   'default'
                 end
      content_tag(:span, status.upcase, class: "label label-#{modifier}")
    end

    def labeled_status(instance)
      return '--' if instance.nil?
      modifier = case instance.status
                 when 'success'
                   'success'
                 when 'canceled'
                   'warning'
                 when 'error'
                   'danger'
                 when 'working'
                   'primary'
                 else
                   'default'
                 end
      content_tag(:span, instance.status.upcase, class: "label label-#{modifier}")
    end

    def first_line(lines)
      lines.split("\n").first
    end

    def distance_of_time(from, to)
      secs  = (to - from).to_i
      mins  = secs / 60
      hours = mins / 60
      days  = hours / 24

      text = ''
      if days > 0
        text << "#{days}days "
      end

      text << "#{sprintf('%02d', hours % 24)}:#{sprintf('%02d', mins % 60)}:#{sprintf('%02d', secs % 60)}"
      text
    end
  end
end

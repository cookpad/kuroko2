module Kuroko2
    module Workflow
      module Task
        class Retry < Base
          def execute
            retry_option = parse_option(option)
            token.context['RETRY'] ||= {}
            node.children.each do |child|
              token.context['RETRY'][child.path] = {
                current: 0,
                count: retry_option['count'].to_i,
                sleep_time: retry_option['sleep_time'].to_i
              }
            end
  
            :next
          end
  
          def validate
            retry_option = parse_option(option)
  
            unless retry_option.has_key?("count")
              raise_assertion_error
            end
          end
  
          private
  
          # e.g count=5 sleep_time=30
          def parse_option(option)
            raise_assertion_error unless option
            retry_option = { "sleep_time" => 0 }
            scanner = StringScanner.new(option)
            until scanner.eos?
              if scanner.scan(/count=(\d+)/)
                retry_option["count"] = scanner[1].to_i
              elsif scanner.scan(/sleep_time=(\d+)/)
                retry_option["sleep_time"] = scanner[1].to_i
              elsif scanner.scan(/\s+|,/)
                # do nothing
              else
                raise_assertion_error
              end
            end
  
            retry_option
          end
  
          def raise_assertion_error
            raise Workflow::AssertionError, "Syntax error option value of retry: #{option}"
          end
        end
      end
    end
  end
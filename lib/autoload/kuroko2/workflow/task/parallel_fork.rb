module Kuroko2
  module Workflow
    module Task
      class ParallelFork < Fork
        def vallidate
          super
          raise Workflow::AssertionError, "ParallelFork must have a parallel size (Int)" unless option.present? && option.match(/\A\d+\z/)
        end

        private

        def parallel_size
          option.to_i
        end

        def extract_child_nodes
          parallel_size.times.each do |index|
            parallel_root = Node.new(:sequence)
            node.children.each { |child| parallel_root.append_child(child) }
            create_child_token(
              child_node: parallel_root,
              env: {
                "KUROKO2_PARALLEL_FORK_SIZE"  => parallel_size.to_s,
                "KUROKO2_PARALLEL_FORK_INDEX" => index.to_s,
              }
            )
          end
        end
      end
    end
  end
end

module MotherBrain
  # @author Jamie Winsor <jamie@vialstudios.com>
  # @private api
  class DynamicInvoker < InvokerBase
    class << self
      # @raise [AbstractFunction] if class is not implementing {#fabricate}
      def fabricate(*args)
        raise AbstractFunction, "Class '#{self}' must implement abstract function"
      end

      protected

        # Define a new Thor command from the given {MotherBrain::Command}
        #
        # @param [MotherBrain::Command] command
        def define_command(command)
          # First argument is always 'environment'
          arguments = []

          command.execute.parameters.each do |type, parameter|
            arguments << parameter.to_s
          end

          description_string = arguments.map(&:upcase).join(" ")
          
          if arguments.any?
            arguments_string = arguments.join(", ")
            command_code = <<-RUBY
              define_method(:#{command.name}) do |#{arguments_string}|
                command.invoke(
                  environment_option,
                  #{arguments_string},
                  force: options[:force]
                )
              end
            RUBY
          else
            command_code = <<-RUBY
              define_method(:#{command.name}) do
                command.invoke(
                  environment_option,
                  force: options[:force]
                )
              end
            RUBY
          end

          method_option :force,
            type: :boolean,
            default: false,
            desc: "Run command even if the environment is locked",
            aliases: "-f"
          desc("#{command.name} #{description_string}", command.description.to_s)
          instance_eval command_code
        end
    end
  end
end

module MotherBrain
  # @author Jamie Winsor <jamie@vialstudios.com>
  module ProxyObject
    include Mixin::SimpleAttributes

    def initialize(&block)
      unless block_given?
        raise PluginSyntaxError, "Block required to evaluate DSL proxy objects"
      end

      instance_eval(&block)
    end

    # @param [String] value
    def name(value)
      set(:name, value, kind_of: String, required: true)
    end
  end
end
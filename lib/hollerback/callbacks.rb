module Hollerback
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)
  end

  module InstanceMethods
    def hollerback_for(callback_block, callback_class: Callbacks, &block)
      self.class.hollerback_for(callback_block, &block)
    end
  end

  module ClassMethods
    def hollerback_for(callback_block, callback_class: Callbacks, &block)
      callbacks = callback_class.new(callback_block)
      block.call(callbacks)
    end
  end

  class Callbacks
    def initialize(block)
      self.tap { |proxy| block.call(proxy) if block }
    end

    def respond_with(callback, *args)
      if callbacks.has_key?(callback)
        callbacks[callback].call(*args)
      else
        raise NoMethodError.new("No callback '#{callback.to_s}'' is defined.")
      end
    end
    def try_respond_with(callback, *args)
      callbacks[callback].call(*args) if callbacks.has_key?(callback)
    end

    def method_missing(m, *args, &block)
      block ? callbacks[m] = block : super
      self
    end

    protected
    def callbacks
      @callbacks ||= {}
    end
  end
end

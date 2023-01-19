# frozen_string_literal: true

require_relative "polyfill/data/version"

if RUBY_VERSION >= "3.2.0"
  warn "You can remove the 'polyfill-data' gem now."
else
  Object.send(:remove_const, :Data) rescue nil
  class Data < Object
    class << self
      undef_method :new
    end

    def self.define(*args, &block)
      raise ArgumentError if args.any?(/=/)
      klass = ::Class.new(self, &block)

      klass.define_singleton_method(:members) { args.map{ _1.intern } }

      klass.define_singleton_method(:new) do |*new_args, **new_kwargs, &block|
        arg_comparison = new_kwargs.any? ? new_kwargs.keys : new_args
        if arg_comparison.size != args.size
          raise ArgumentError
        end
        self.allocate.tap do |instance|
          args_to_hash = if !new_kwargs.any?
            Hash[members.take(new_args.size).zip(new_args)]
          else
            new_kwargs
          end
          instance.send(:initialize, **args_to_hash, &block)
        end
      end

      args.map do |arg|
        if klass.method_defined?(arg)
          raise ArgumentError, "duplicate member #{arg}"
        end
        klass.define_method(arg) do
          @attributes[arg]
        end
      end

      klass
    end

    def members
      self.class.members
    end

    def initialize(*args, **kwargs)
      @attributes = case
      when args.empty? && kwargs.empty?
        {}
      when args.empty?
        kwargs
      else
        raise ArgumentError unless args.length == members.length
        Hash[members.zip(args)]
      end
    end

    def deconstruct_keys(array)
      raise TypeError unless array.is_a?(Array) || array.nil?
      return @attributes if array&.first.nil?

      @attributes.slice(*array)
    end

    def to_h(&block)
      @attributes.to_h(&block)
    end

    def hash
      to_h.hash
    end

    def eql?(other)
      self.class == other.class && hash == other.hash
    end

    def ==(other)
      self.class == other.class && to_h == other.to_h
    end

    def inspect
      name = ["data", self.class.name].compact.join(" ")
      attribute_markers = @attributes.map do |key, value|
        insect_key = key.to_s.start_with?("@") ? ":#{key}" : key
        "#{insect_key}=#{value}"
      end
      %(#<#{name} #{attribute_markers.join(" ")}>)
    end

    def with(**kwargs)
      self.class.new(*@attributes.merge(kwargs).values)
    end
  end
end

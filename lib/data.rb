# frozen_string_literal: true

require_relative "polyfill/data/version"

if RUBY_VERSION >= "3.2.0"
  warn "You can remove the 'polyfill-data' gem now."
else
  Object.send(:remove_const, :Data) rescue nil
  class Data < Object
    class << self
      undef_method :new
      attr_reader :members
    end

    def self.define(*args, &block)
      raise ArgumentError if args.any?(/=/)
      klass = ::Class.new(self, &block)

      if args.first.is_a?(String)
        name = args.shift
        Data.const_set(name, klass)
      end

      klass.instance_variable_set(:@members, args)

      klass.define_singleton_method(:new) do |*new_args, **new_kwargs, &block|
        init_kwargs = if new_args.any?
          raise ArgumentError, "unknown arguments #{new_args[members.size..].join(', ')}" if new_args.size > members.size
          Hash[members.take(new_args.size).zip(new_args)]
        else
          new_kwargs
        end

        self.allocate.tap do |instance|
          instance.send(:initialize, **init_kwargs, &block)
        end.freeze
      end
      class << klass
        alias_method :[], :new
        undef_method :define
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

    def initialize(**kwargs)
      kwargs_size = kwargs.size
      members_size = members.size

      if kwargs_size > members_size
        extras = kwargs.reject{|k, _v| members.include?(k) }.keys
        raise ArgumentError, "unknown arguments #{extras.join(', ')}"
      elsif kwargs_size < members_size
        missing = members.select {|k, _v| !kwargs.include?(k) }
        raise ArgumentError, "missing arguments #{missing.map{ ":#{_1}" }.join(', ')}"
      end

      @attributes = Hash[members.map {|m| [m,kwargs[m]] }]
    end

    def deconstruct
      @attributes.values
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
      %(#<#{name} #{attribute_markers.join(", ")}>)
    end
    alias_method :to_s, :inspect

    def with(**kwargs)
      return self if kwargs.empty?

      self.class.new(**@attributes.merge(kwargs))
    end

    private

    def initialize_copy(source)
      super.freeze
    end
  end
end

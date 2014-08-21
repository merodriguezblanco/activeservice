module ActiveService
  module Model
    module Associations
      class Association
        # @private
        attr_accessor :params

        # @private
        def initialize(owner, opts = {})
          @owner = owner
          @opts = opts
          @params = {}

          @klass = @owner.class.nearby_class(@opts[:class_name])
          @name = @opts[:name]
        end

        # @private
        def self.proxy(parent, opts = {})
          AssociationProxy.new new(parent, opts)
        end

        # @private
        def self.parse_single(association, klass, data)
          data_key = association[:data_key]
          return {} unless data[data_key]

          klass = klass.nearby_class(association[:class_name])
          if data[data_key].kind_of?(klass)
            { association[:name] => data[data_key] }
          else
            { association[:name] => klass.new(data[data_key]) }
          end
        end

        # @private
        def assign_single_nested_attributes(attributes)
          if @owner.attributes[@name].blank?
            @owner.attributes[@name] = @klass.new(@klass.parse(attributes))
          else
            @owner.attributes[@name].assign_attributes(attributes)
          end
        end

        # @private
        def fetch(opts = {})
          attribute_value = @owner.attributes[@name]
          return @opts[:default].try(:dup) if @owner.attributes.include?(@name) && (attribute_value.nil? || !attribute_value.nil? && attribute_value.empty?) && @params.empty?

          return @cached_result unless @params.any? || @cached_result.nil?
          return @owner.attributes[@name] unless @params.any? || @owner.attributes[@name].blank?
          
          path = build_association_path lambda { "#{@owner.request_path(@params)}#{@opts[:path]}" }
          @klass.get(path, @params).tap do |result|
            @cached_result = result unless @params.any?
          end
        end

        # @private
        def build_association_path(code)
          begin
            instance_exec(&code)
          rescue ActiveService::Errors::PathError
            return nil
          end
        end

        # Add query parameters to the HTTP request performed to fetch the data
        #
        # @example
        #   class User < ActiveService::Model
        #     has_many :comments
        #   end
        #
        #   user = User.find(1)
        #   user.comments.where(:approved => 1) # Fetched via GET "/users/1/comments?approved=1
        def where(params = {})
          return self if params.blank? && @owner.attributes[@name].blank?
          AssociationProxy.new self.clone.tap { |a| a.params = a.params.merge(params) }
        end
        alias all where

        # Fetches the data specified by id
        #
        # @example
        #   class User < ActiveService::Model
        #     has_many :comments
        #   end
        #
        #   user = User.find(1)
        #   user.comments.find(3) # Fetched via GET "/users/1/comments/3
        def find(id)
          return nil if id.blank?
          path = build_association_path lambda { "#{@owner.request_path(@params)}#{@opts[:path]}/#{id}" }
          @klass.get(path, @params)
        end

      end
    end
  end
end

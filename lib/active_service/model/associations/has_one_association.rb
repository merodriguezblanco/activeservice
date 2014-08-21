module ActiveService
  module Model
    module Associations
      class HasOneAssociation < Association

        # @private
        def self.attach(klass, name, opts)
          opts = {
            :class_name => name.to_s.classify,
            :name => name,
            :data_key => name,
            :default => nil,
            :path => "/#{name}"
          }.merge(opts)
          klass.associations[:has_one] << opts

          klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}
              cached_name = :"@association_#{name}"

              cached_data = (instance_variable_defined?(cached_name) && instance_variable_get(cached_name))
              cached_data || instance_variable_set(cached_name, ActiveService::Model::Associations::HasOneAssociation.proxy(self, #{opts.inspect}))
            end
          RUBY
        end

        # @private
        def self.parse(*args)
          parse_single(*args)
        end

        # Initialize a new object with a foreign key to the parent
        #
        # @example
        #   class User < ActiveService::Base
        #     has_one :role
        #   end
        #
        #   class Role < ActiveService::Base
        #   end
        #
        #   user = User.find(1)
        #   new_role = user.role.build(:title => "moderator")
        #   new_role # => #<Role user_id=1 title="moderator">
        def build(attributes = {})
          @klass.build(attributes.merge(:"#{@owner.singularized_resource_name}_id" => @owner.id))
        end

        # Create a new object, save it and associate it to the parent
        #
        # @example
        #   class User < ActiveService::Base
        #     has_one :role
        #   end
        #
        #   class Role < ActiveService::Base
        #   end
        #
        #   user = User.find(1)
        #   user.role.create(:title => "moderator")
        #   user.role # => #<Role id=2 user_id=1 title="moderator">
        def create(attributes = {})
          resource = build(attributes)
          @owner.attributes[@name] = resource if resource.save
          resource
        end

        # @private
        def assign_nested_attributes(attributes)
          assign_single_nested_attributes(attributes)
        end
      end
    end
  end
end

# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: active_service 1.4.4 ruby lib

Gem::Specification.new do |s|
  s.name = "active_service"
  s.version = "1.4.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["zwelchcb"]
  s.date = "2016-08-19"
  s.description = "ActiveService is an ORM that maps REST resources to Ruby objects using an ActiveRecord-like interface."
  s.email = "Zachary.Welch@careerbuilder.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".codeclimate.yml",
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "active_service.gemspec",
    "config/.rubocop.yml",
    "lib/active_service.rb",
    "lib/active_service/api.rb",
    "lib/active_service/base.rb",
    "lib/active_service/collection.rb",
    "lib/active_service/errors.rb",
    "lib/active_service/middleware.rb",
    "lib/active_service/middleware/parse_json.rb",
    "lib/active_service/model.rb",
    "lib/active_service/model/aggregations.rb",
    "lib/active_service/model/associations.rb",
    "lib/active_service/model/associations/association.rb",
    "lib/active_service/model/associations/association_proxy.rb",
    "lib/active_service/model/associations/belongs_to_association.rb",
    "lib/active_service/model/associations/has_and_belongs_to_many_association.rb",
    "lib/active_service/model/associations/has_many_association.rb",
    "lib/active_service/model/associations/has_one_association.rb",
    "lib/active_service/model/attributes.rb",
    "lib/active_service/model/attributes/attribute_map.rb",
    "lib/active_service/model/attributes/nested_attributes.rb",
    "lib/active_service/model/errors.rb",
    "lib/active_service/model/http.rb",
    "lib/active_service/model/introspection.rb",
    "lib/active_service/model/orm.rb",
    "lib/active_service/model/parse.rb",
    "lib/active_service/model/paths.rb",
    "lib/active_service/model/relation.rb",
    "lib/active_service/model/serialization.rb",
    "lib/active_service/version.rb",
    "lib/ext/active_attr/attribute_definition.rb",
    "lib/ext/active_attr/attributes.rb",
    "pkg/active_service-0.1.0.gem",
    "pkg/active_service-1.0.0.gem",
    "pkg/active_service-1.0.1.gem",
    "pkg/active_service-1.0.2.gem",
    "pkg/active_service-1.0.3.gem",
    "pkg/active_service-1.0.4.gem",
    "spec/api_spec.rb",
    "spec/collection_spec.rb",
    "spec/errors_spec.rb",
    "spec/ext/attributes_spec.rb",
    "spec/middleware/json_parser_spec.rb",
    "spec/model/aggregations_spec.rb",
    "spec/model/associations_spec.rb",
    "spec/model/attribute_map_spec.rb",
    "spec/model/attributes_spec.rb",
    "spec/model/coverage/.last_run.json",
    "spec/model/coverage/.resultset.json",
    "spec/model/coverage/.resultset.json.lock",
    "spec/model/coverage/assets/0.10.0/application.css",
    "spec/model/coverage/assets/0.10.0/application.js",
    "spec/model/coverage/assets/0.10.0/colorbox/border.png",
    "spec/model/coverage/assets/0.10.0/colorbox/controls.png",
    "spec/model/coverage/assets/0.10.0/colorbox/loading.gif",
    "spec/model/coverage/assets/0.10.0/colorbox/loading_background.png",
    "spec/model/coverage/assets/0.10.0/favicon_green.png",
    "spec/model/coverage/assets/0.10.0/favicon_red.png",
    "spec/model/coverage/assets/0.10.0/favicon_yellow.png",
    "spec/model/coverage/assets/0.10.0/loading.gif",
    "spec/model/coverage/assets/0.10.0/magnify.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-bg_flat_0_aaaaaa_40x100.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-bg_flat_75_ffffff_40x100.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-bg_glass_55_fbf9ee_1x400.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-bg_glass_65_ffffff_1x400.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-bg_glass_75_dadada_1x400.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-bg_glass_75_e6e6e6_1x400.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-bg_glass_95_fef1ec_1x400.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-bg_highlight-soft_75_cccccc_1x100.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-icons_222222_256x240.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-icons_2e83ff_256x240.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-icons_454545_256x240.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-icons_888888_256x240.png",
    "spec/model/coverage/assets/0.10.0/smoothness/images/ui-icons_cd0a0a_256x240.png",
    "spec/model/coverage/assets/0.8.0/application.css",
    "spec/model/coverage/assets/0.8.0/application.js",
    "spec/model/coverage/assets/0.8.0/colorbox/border.png",
    "spec/model/coverage/assets/0.8.0/colorbox/controls.png",
    "spec/model/coverage/assets/0.8.0/colorbox/loading.gif",
    "spec/model/coverage/assets/0.8.0/colorbox/loading_background.png",
    "spec/model/coverage/assets/0.8.0/favicon_green.png",
    "spec/model/coverage/assets/0.8.0/favicon_red.png",
    "spec/model/coverage/assets/0.8.0/favicon_yellow.png",
    "spec/model/coverage/assets/0.8.0/loading.gif",
    "spec/model/coverage/assets/0.8.0/magnify.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-bg_flat_0_aaaaaa_40x100.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-bg_flat_75_ffffff_40x100.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-bg_glass_55_fbf9ee_1x400.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-bg_glass_65_ffffff_1x400.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-bg_glass_75_dadada_1x400.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-bg_glass_75_e6e6e6_1x400.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-bg_glass_95_fef1ec_1x400.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-bg_highlight-soft_75_cccccc_1x100.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-icons_222222_256x240.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-icons_2e83ff_256x240.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-icons_454545_256x240.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-icons_888888_256x240.png",
    "spec/model/coverage/assets/0.8.0/smoothness/images/ui-icons_cd0a0a_256x240.png",
    "spec/model/coverage/index.html",
    "spec/model/errors_spec.rb",
    "spec/model/http_spec.rb",
    "spec/model/nested_attributes_spec.rb",
    "spec/model/orm_spec.rb",
    "spec/model/parse_spec.rb",
    "spec/model/paths_spec.rb",
    "spec/model/relation_spec.rb",
    "spec/model_spec.rb",
    "spec/spec_helper.rb",
    "spec/support/macros/model_macros.rb",
    "spec/support/macros/request_macros.rb",
    "spec/support/utilities.rb"
  ]
  s.homepage = "http://github.com/zwelchcb/active_service"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.3"
  s.summary = "An object-relational mapper for web services."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<active_attr>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
      s.add_development_dependency(%q<rspec-its>, ["~> 1.0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<fivemat>, ["~> 1.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_development_dependency(%q<faraday_middleware>, ["~> 0.9"])
      s.add_development_dependency(%q<typhoeus>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<pry-byebug>, [">= 0"])
      s.add_runtime_dependency(%q<faraday>, ["< 1.0", ">= 0.8"])
    else
      s.add_dependency(%q<active_attr>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
      s.add_dependency(%q<rspec-its>, ["~> 1.0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<fivemat>, ["~> 1.2"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_dependency(%q<faraday_middleware>, ["~> 0.9"])
      s.add_dependency(%q<typhoeus>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<pry-byebug>, [">= 0"])
      s.add_dependency(%q<faraday>, ["< 1.0", ">= 0.8"])
    end
  else
    s.add_dependency(%q<active_attr>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
    s.add_dependency(%q<rspec-its>, ["~> 1.0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<fivemat>, ["~> 1.2"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
    s.add_dependency(%q<faraday_middleware>, ["~> 0.9"])
    s.add_dependency(%q<typhoeus>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<pry-byebug>, [">= 0"])
    s.add_dependency(%q<faraday>, ["< 1.0", ">= 0.8"])
  end
end


# encoding: utf-8
require File.join(File.dirname(__FILE__), "../spec_helper.rb")

describe ActiveService::Model::Parse do
  context "when include_root_in_json is set" do
    context "to true" do
      before do
        api = ActiveService::API.setup url: "https://api.example.com" do |builder|
          builder.use Faraday::Request::UrlEncoded
          builder.use ActiveService::Middleware::ParseJSON
          builder.adapter :test do |stub|
            stub.post("/users") { |env| ok! user: { id: 1, name: params(env)[:user][:name] } }
            stub.post("/users/admins") { |env| ok! user: { id: 1, name: params(env)[:user][:name] } }
          end
        end

        spawn_model "User" do
          uses_api api
          attribute :name
          include_root_in_json true
          parse_root_in_json true
          custom_post :admins, on: :member
        end
      end

      it "wraps params in the element name in `to_params`" do
        user = User.new(name: "Tobias Fünke")
        expect(user.to_params).to eq({ user: { name: "Tobias Fünke", id: nil } })
      end

      it "wraps params in the element name in `.create`" do
        user = User.admins(name: "Tobias Fünke")
        expect(user.name).to eq "Tobias Fünke"
      end
    end

    context "to a symbol" do
      before do
        spawn_model "User" do
          attribute :name
          include_root_in_json :person
          parse_root_in_json :person
        end
      end

      it "wraps params in the specified value" do
        user = User.new(name: "Tobias Fünke")
        expect(user.to_params).to eq({ person: { name: "Tobias Fünke", id: nil } })
      end
    end

    context "in the parent class" do
      before do
        spawn_model "Model" do
          include_root_in_json true
        end

        class User < Model
          attribute :name
        end
        @spawned_models << :User
      end

      it "wraps params with the class name" do
        user = User.new(name: "Tobias Fünke")
        expect(user.to_params).to eq({ user: { name: "Tobias Fünke", id: nil } })
      end
    end
  end

  context "when parse_root_in_json is set" do
    context "to true" do
      before do
        api = ActiveService::API.setup url: "https://api.example.com" do |builder|
          builder.use Faraday::Request::UrlEncoded
          builder.use ActiveService::Middleware::ParseJSON
          builder.adapter :test do |stub|
            stub.post("/users") { |env| ok! user: { id: 1, name: "Lindsay Fünke" } }
            stub.get("/users") { |env| ok! [{ user: { id: 1, name: "Lindsay Fünke" } }] }
            stub.get("/users/admins") { |env| ok! [{ user: { id: 1, name: "Lindsay Fünke" } }] }
            stub.get("/users/1") { |env| ok! user: { id: 1, name: "Lindsay Fünke" } }
            stub.put("/users/1") { |env| ok! user: { id: 1, name: "Tobias Fünke Jr." } }
          end
        end

        spawn_model "User" do
          uses_api api
          attribute :name
          custom_get :admins, on: :collection
          parse_root_in_json true
        end
      end

      it "parse the data from the JSON root element after .create" do
        user = User.create(name: "Lindsay Fünke")
        expect(user.name).to eq "Lindsay Fünke"
      end

      it "parse the data from the JSON root element after an arbitrary HTTP request" do
        user = User.admins
        expect(user.first.name).to eq "Lindsay Fünke"
      end

      it "parse the data from the JSON root element after .all" do
        users = User.all
        expect(users.first.name).to eq "Lindsay Fünke"
      end

      it "parse the data from the JSON root element after .find" do
        user = User.find(1)
        expect(user.name).to eq "Lindsay Fünke"
      end

      it "parse the data from the JSON root element after .save" do
        user = User.find(1)
        user.name = "Tobias Fünke"
        user.save
        expect(user.name).to eq "Tobias Fünke Jr."
      end
    end

    context "to a symbol" do
      before do
        api = ActiveService::API.setup url: "https://api.example.com" do |builder|
          builder.use Faraday::Request::UrlEncoded
          builder.use ActiveService::Middleware::ParseJSON
          builder.adapter :test do |stub|
            stub.post("/users") { |env| ok! person: { id: 1, name: "Lindsay Fünke" } }
          end
        end

        spawn_model "User" do
          uses_api api
          attribute :name
          parse_root_in_json :person
        end
      end

      it "parse the data with the symbol" do
        user = User.create(name: "Lindsay Fünke")
        expect(user.name).to eq "Lindsay Fünke"
      end
    end

    context "in the parent class" do
      before do
        api = ActiveService::API.setup url: "https://api.example.com" do |builder|
          builder.use Faraday::Request::UrlEncoded
          builder.use ActiveService::Middleware::ParseJSON
          builder.adapter :test do |stub|
            stub.post("/users") { |env| ok! user: { id: 1, name: "Lindsay Fünke" } }
            stub.get("/users") { |env| ok! users: [ { id: 1, name: "Lindsay Fünke" } ] }
          end
        end

        spawn_model "Model" do
          uses_api api
          parse_root_in_json true, format: :active_model_serializers
        end

        class User < Model
          attribute :name
          collection_path "/users"
        end

        @spawned_models << :User
      end

      it "parse the data with the symbol" do
        user = User.create(name: "Lindsay Fünke")
        expect(user.name).to eq "Lindsay Fünke"
      end

      it "parses the collection of data" do
        users = User.all
        expect(users.first.name).to eq "Lindsay Fünke"
      end
    end

    context "to true with format: :active_model_serializers" do
      before do
        api = ActiveService::API.setup url: "https://api.example.com" do |builder|
          builder.use Faraday::Request::UrlEncoded
          builder.use ActiveService::Middleware::ParseJSON
          builder.adapter :test do |stub|
            stub.post("/users") { |env| ok! user: { id: 1, name: "Lindsay Fünke" } }
            stub.get("/users") { |env| ok! users: [ { id: 1, name: "Lindsay Fünke" } ] }
            stub.get("/users/admins") { |env| ok! users: [ { id: 1, name: "Lindsay Fünke" } ] }
            stub.get("/users/1") { |env| ok! user: { id: 1, name: "Lindsay Fünke" } }
            stub.put("/users/1") { |env| ok! user: { id: 1, name: "Tobias Fünke Jr." } }
          end
        end

        spawn_model "User" do
          uses_api api
          attribute :name
          parse_root_in_json true, format: :active_model_serializers
          custom_get :admins, on: :collection
        end
      end

      it "parse the data from the JSON root element after .create" do
        user = User.create(name: "Lindsay Fünke")
        expect(user.name).to eq "Lindsay Fünke"
      end

      it "parse the data from the JSON root element after an arbitrary HTTP request" do
        users = User.admins
        expect(users.first.name).to eq "Lindsay Fünke"
      end

      it "parse the data from the JSON root element after .all" do
        users = User.all
        expect(users.first.name).to eq "Lindsay Fünke"
      end

      it "parse the data from the JSON root element after .find" do
        user = User.find(1)
        expect(user.name).to eq "Lindsay Fünke"
      end

      it "parse the data from the JSON root element after .save" do
        user = User.find(1)
        user.name = "Tobias Fünke"
        user.save
        expect(user.name).to eq "Tobias Fünke Jr."
      end
    end
  end

  context "when to_params is set" do
    before do
      api = ActiveService::API.setup url: "https://api.example.com" do |builder|
        builder.use Faraday::Request::UrlEncoded
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.post("/users") { |env| ok! id: 1, name: params(env)['name'] }
        end
      end

      spawn_model "User" do
        uses_api api
        attribute :name
        def to_params
          { id: nil, name: "Lindsay Fünke" }
        end
      end
    end

    it "changes the request parameters for one-line resource creation" do
      user = User.create(name: "Tobias Fünke")
      expect(user.name).to eq "Lindsay Fünke"
    end

    it "changes the request parameters for Model.new + #save" do
      user = User.new(name: "Tobias Fünke")
      user.save
      expect(user.name).to eq "Lindsay Fünke"
    end
  end

  context "when parse_root_in_json set json_api to true" do
    before do
      api = ActiveService::API.setup url: "https://api.example.com" do |builder|
        builder.use Faraday::Request::UrlEncoded
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.get("/users") { |env| ok! users: [{ id: 1, name: "Lindsay Fünke" }] }
          stub.get("/users/admins") { |env| ok! users: [{ id: 1, name: "Lindsay Fünke" }] }
          stub.get("/users/1") { |env| ok! users: [{ id: 1, name: "Lindsay Fünke" }] }
          stub.post("/users") { |env| ok! users: [{ id: 1, name: "Lindsay Fünke" }] }
          stub.put("/users/1") { |env| ok! users: [{ id: 1, name: "Tobias Fünke Jr." }] }
        end
      end

      spawn_model "User" do
        uses_api api
        parse_root_in_json true, format: :json_api
        include_root_in_json true
        custom_get :admins, on: :collection
        attribute :name
      end
    end

    it "parse the data from the JSON root element after .create" do
      user = User.create(name: "Lindsay Fünke")
      expect(user.name).to eq "Lindsay Fünke"
    end

    it "parse the data from the JSON root element after an arbitrary HTTP request" do
      user = User.admins
      expect(user.first.name).to eq "Lindsay Fünke"
    end

    it "parse the data from the JSON root element after .all" do
      users = User.all
      expect(users.first.name).to eq "Lindsay Fünke"
    end

    it "parse the data from the JSON root element after .find" do
      user = User.find(1)
      expect(user.name).to eq "Lindsay Fünke"
    end

    it "parse the data from the JSON root element after .save" do
      user = User.find(1)
      user.name = "Tobias Fünke"
      user.save
      expect(user.name).to eq "Tobias Fünke Jr."
    end

    it "parse the data from the JSON root element after new/save" do
      user = User.new
      user.name = "Lindsay Fünke (before save)"
      user.save
      expect(user.name).to eq "Lindsay Fünke"
    end
  end

  context "when include_root_in_json set json_api" do
    before do
      api = ActiveService::API.setup url: "https://api.example.com" do |builder|
        builder.use Faraday::Request::UrlEncoded
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.post("/users") { |env| ok! users: [{ id: 1, name: params(env)[:users][:name] }] }
        end
      end
    end

    context "to true" do
      before do
        spawn_model "User" do
          uses_api api
          include_root_in_json true
          parse_root_in_json true, format: :json_api
          custom_post :admins, on: :collection
          attribute :name
        end
      end

      it "wraps params in the element name in `to_params`" do
        user = User.new(name: "Tobias Fünke")
        expect(user.to_params).to eq({ users: [{ name: "Tobias Fünke", id: nil }] })
      end

      it "wraps params in the element name in `.where`" do
        user = User.where(name: "Tobias Fünke").build
        expect(user.name).to eq"Tobias Fünke"
      end
    end
  end

  context 'when send_only_modified_attributes is set' do
    pending
  end

  context "when a custom collection exists" do
    before do
      class CustomCollection < ActiveService::Collection
        attr_reader :total_count
        def initialize(parsed = {})
          @elements = parsed[:collection]
          @total_count = parsed[:total_count]
        end
      end

      api = ActiveService::API.new url: "https://api.example.com" do |builder|
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.get("/users") { |env| [200, {}, { collection: [{ id: 1, name: "Tobias Fünke" }], total_count: 100 }.to_json] }
          stub.get("/super_users") { |env| [200, {}, { collection: [{ id: 1, name: "Tobias Fünke" }], total_count: 100 }.to_json] }
          stub.get("/users/active") { |env| [200, {}, { collection: [{ id: 1, name: "Tobias Fünke" }], total_count: 50 }.to_json] }
        end
      end

      spawn_model "User" do
        uses_api api
        collection_parser CustomCollection
        attribute :name
      end

      spawn_model "SuperUser" do
        uses_api api
        attribute :name
      end
    end

    context "when the custom collection is set" do
      it "handles parsing the collection" do
        users = User.all
        expect(users).to be_kind_of(CustomCollection)
        expect(users.length).to be 1
        expect(users.first.name).to eq "Tobias Fünke"
      end

      it "handles other methods on custom collection" do
        users = User.all
        expect(users.respond_to?(:total_count)).to be_truthy
        expect(users.total_count).to be 100
      end

      it "handles custom_get on custom collection" do
        User.custom_get :active, on: :collection
        users = User.active
        expect(users.respond_to?(:total_count)).to be_truthy
        expect(users.total_count).to be 50
      end
    end

    context "when custom collection is not set" do
      it "raises a ParserError" do
        super_users = SuperUser.all
        expect { super_users.first }.to raise_error(ActiveService::Errors::ParserError)
      end
    end
  end

  describe "#to_params" do
    context "with single has_one association" do
      before do
        spawn_model "User" do
          attribute :name
          has_one :role
        end

        spawn_model "Role" do
          attribute :name
        end
      end

      it "includes has_one associations" do
        user = User.new(name: "Tobias Fünke")
        user.role = Role.new(name: "admin")

        expect(user.to_params[:role]).to eq({ name: "admin", id: nil })
      end
    end

    context "with multiple has_one associations" do
      before do
        spawn_model "User" do
          attribute :name
          has_one :address
          has_one :role
        end

        spawn_model "Role" do
          attribute :name
        end

        spawn_model "Address" do
          attribute :street
        end
      end

      it "includes nil has_one association" do
        user = User.new(name: "Tobias Fünke")
        user.role = Role.new(name: "admin")
        user.address = nil

        expect(user.to_params[:role]).to eq({ name: "admin", id: nil })
        expect(user.to_params[:address]).to be_nil
      end
    end

    context "with single has_many association" do
      before do
        spawn_model "User" do
          attribute :name
          has_many :comments
        end

        spawn_model "Comment" do
          attribute :body
        end
      end

      it "includes has_many associations" do
        user = User.new(name: "Tobias Fünke")
        user.comments = [Comment.new(body:"lorem ipsum")]

        expect(user.to_params[:comments]).to eq([{ body: "lorem ipsum", id: nil }])
      end
    end

    context "with multiple has_many associations" do
      before do
        spawn_model "User" do
          attribute :name
          has_many :posts
          has_many :comments
        end

        spawn_model "Comment" do
          attribute :body
        end

        spawn_model "Post" do
          attribute :body
        end
      end

      it "includes empty has_many association" do
        user = User.new(name: "Tobias Fünke")
        user.comments = [Comment.new(body:"lorem ipsum")]
        user.posts = []

        expect(user.to_params[:comments]).to eq([{ body: "lorem ipsum", id: nil }])
        expect(user.to_params[:posts]).to be_empty
      end
    end
  end
end

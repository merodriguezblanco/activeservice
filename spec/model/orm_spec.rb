# encoding: utf-8
require File.join(File.dirname(__FILE__), "../spec_helper.rb")

describe ActiveService::Model::ORM do

  context "mapping data to Ruby objects" do
    before do
      api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.get("/users/1") { |env| ok! :id => 1, :name => "Tobias Fünke" }
          stub.get("/users") { |env| ok! [{ :id => 1, :name => "Tobias Fünke" }, { :id => 2, :name => "Lindsay Fünke" }] }
        end
      end

      spawn_model "User" do
        uses_api api
        attribute :name
      end

      spawn_model "AdminUser" do
        uses_api api
        primary_key :admin_id
      end      
    end

    it "maps a single resource to a Ruby object" do
      @user = User.find(1)
      expect(@user.id).to be 1
      expect(@user.name).to eq "Tobias Fünke"
    end

    it "maps a collection of resources to an array of Ruby objects" do
      @users = User.all
      expect(@users.length).to be 2
      expect(@users.first.name).to eq "Tobias Fünke"
    end

    it "handles new resource" do
      @new_user = User.new(:name => "Tobias Fünke")
      expect(@new_user.new?).to be_truthy
      expect(@new_user.name).to eq "Tobias Fünke"

      @existing_user = User.find(1)
      expect(@existing_user.new?).to be_falsey
    end

    xit "handles new resource with custom primary key" do
      @new_user = AdminUser.new(:name => "Lindsay Fünke", :id => -1)
      expect(@new_user).to be_new

      @existing_user = AdminUser.find(1)
      expect(@existing_user).to be_new
    end
  end

  context "mapping errors to Ruby objects" do
    before do
      api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
        builder.use Faraday::Request::UrlEncoded
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.get("/users/1") { |env| ok! :id => 1, :email => "tfunke@example.com" }
          stub.put("/users/1") { |env| error! :email => ["is invalid"] }
          stub.post("/users") { |env| error! :email => ["is invalid"] }
        end
      end

      spawn_model :User do
        uses_api api
        attribute :email
      end
    end

    it "handle errors through #create" do
      @user = User.create(:email => "invalid@email")
      expect(@user.errors.count).to be 1
    end

    it "keeps values when errors are returned through #create" do
      @user = User.create(:email => "invalid@email")
      expect(@user.email).to eq "invalid@email"
    end

    it "handle errors through #save on an existing resource" do
      @user = User.find(1)
      @user.email = "invalid@email"
      @user.save
      expect(@user.errors.count).to be 1
    end

    it "handles new errors through #save on an existing resource" do
      @user = User.find(1)
      @user.email = "invalid@email"
      @user.save
      expect(@user.errors.count).to be 1
      @user.save
      expect(@user.errors.count).to be 1
    end    

    it "handle errors through #update_attributes" do
      @user = User.find(1)
      @user.update_attributes(:email => "invalid@email")
      expect(@user.errors.count).to be 1
    end    

    it "handle errors through Model.new + #save" do
      @user = User.new(:email => "invalid@email")
      @user.save
      expect(@user.errors.count).to be 1
    end

    it "handle errors through Model.new + #save!" do
      @user = User.new(:email => "invalid@email")
      expect { @user.save! }.to raise_error ActiveService::Errors::ResourceInvalid
      expect(@user.errors.count).to be 1
    end
  end

  context "finding resources" do
    before do
      api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.get("/users/1") { |env| ok! :id => 1, :name => "Tobias Fünke" }
          stub.get("/users/2") { |env| ok! :id => 2, :name => "Lindsay Fünke" }
          stub.get("/users?id[]=1&id[]=2") { |env| ok! [{ :id => 1, :name => "Tobias Fünke" }, { :id => 2, :name => "Lindsay Fünke" }] }
          stub.get("/users?name=foo") { |env| ok! [{ :id => 3, :name => "foo" }] }
          stub.get("/users?name=bar") { |env| ok! [{ :id => 4, :name => "bar" }] }
        end
      end

      spawn_model "User" do
        attribute :name
        use_api api
      end
    end

    it "handles finding by a single id" do
      @user = User.find(1)
      expect(@user.id).to be 1      
    end

    it "handles finding by multiple ids" do
      @users = User.find(1, 2)
      expect(@users).to be_kind_of(Array)
      expect(@users.length).to be 2
      expect(@users[0].id).to be 1
      expect(@users[1].id).to be 2      
    end

    it "handles finding by an array of ids" do
      @users = User.find([1, 2])
      expect(@users).to be_kind_of(Array)
      expect(@users.length).to be 2
      expect(@users[0].id).to be 1
      expect(@users[1].id).to be 2      
    end

    it "handles finding by an array of ids of length 1" do
      @users = User.find([1])
      expect(@users).to be_kind_of(Array)
      expect(@users.length).to be 1
      expect(@users[0].id).to be 1      
    end

    it "handles finding by an array id param of length 2" do
      @users = User.find(id: [1, 2])
      expect(@users).to be_kind_of(Array)
      expect(@users.length).to be 2
      expect(@users[0].id).to be 1
      expect(@users[1].id).to be 2
    end

    it "handles finding with id parameter as an array" do
      @users = User.where(id: [1, 2])
      expect(@users).to be_kind_of(ActiveService::Collection)
      expect(@users.length).to be 2
      expect(@users[0].id).to be 1
      expect(@users[1].id).to be 2      
    end

    it "handles finding with other parameters" do
      @users = User.where(:name => "foo")
      expect(@users).to be_kind_of(ActiveService::Collection)
      expect(@users.first.id).to be 3
      expect(@users.first.name).to eq "foo"
    end

    it "handles finding with other parameters and scoped" do
      @users = User.scoped
      expect(@users.where(:name => "foo")).to be_all { |u| u.name eq "foo" }
    end
  end

  context "building resources" do
    context "when request_new_object_on_build is not set (default)" do
      before do
        spawn_model "User" do
          attribute :name
        end
      end

      it "builds a new resource without requesting it" do
        expect(User).to receive(:request).never
        @new_user = User.build(:name => "Tobias Fünke")
        expect(@new_user.new?).to be_truthy
        expect(@new_user.name).to eq "Tobias Fünke"
      end
    end

    context "when request_new_object_on_build is set" do
      before do
        api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
          builder.use ActiveService::Middleware::ParseJSON
          builder.adapter :test do |stub|
            stub.get("/users/new") { |env| ok! :id => nil, :name => params(env)[:name], :email => "tobias@bluthcompany.com" }
          end
        end

        spawn_model "User" do
          uses_api api
          attribute :name
          attribute :email
          request_new_object_on_build true
        end 
      end

      it "requests a new resource" do
        expect(User).to receive(:request).once.and_call_original
        @new_user = User.build(:name => "Tobias Fünke")
        expect(@new_user.new?).to be_truthy
        expect(@new_user.name).to eq "Tobias Fünke"
        expect(@new_user.email).to eq "tobias@bluthcompany.com"
      end
    end    
  end

  context "creating resources" do
    before do
      api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.post("/users") { |env| ok! :id => 1, :name => "Tobias Fünke" }
          stub.post("/companies") { |env| error! name: ["can't be blank"] }
        end
      end

      spawn_model "User" do
        attribute :name
        use_api api
      end
      
      spawn_model "Company" do
        use_api api
        attribute :name
        validates :name, presence: true
      end
    end

    it "handle one-line resource creation" do
      @user = User.create(:name => "Tobias Fünke")
      expect(@user.id).to be 1
      expect(@user.name).to eq "Tobias Fünke"
    end

    it "handle resource creation through Model.new + #save" do
      @user = User.new(:name => "Tobias Fünke")
      expect(@user.save).to be_truthy
      expect(@user.name).to eq "Tobias Fünke"
    end

    it "handle resource creation through Model.new + #save!" do
      @user = User.new(:name => "Tobias Fünke")
      expect(@user.save!).to be_truthy
      expect(@user.name).to eq "Tobias Fünke"
    end    

    it "returns false when #save gets errors" do
      @company = Company.new
      expect(@company.save).to be_falsey
    end    

    it "raises ResourceInvalid when #save! gets errors" do
      @company = Company.new
      expect { @company.save! }.to raise_error ActiveService::Errors::ResourceInvalid
    end

    it "don't overwrite data if response is empty" do
      @company = Company.new(:name => "Company Inc.")
      expect(@company.save).to be_falsey
      expect(@company.name).to eq "Company Inc."
    end    
  end

  context "updating resources" do
    before do
      api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.get("/users/1") { |env| ok! :id => 1, :name => "Tobias Fünke" }
          stub.put("/users/1") { |env| ok! :id => 1, :name => "Lindsay Fünke" }
        end
      end

      spawn_model "User" do
        uses_api api
        attribute :name
      end
    end

    it "handle resource data update without saving it" do
      @user = User.find(1)
      expect(@user.name).to eq "Tobias Fünke"
      @user.name = "Kittie Sanchez"
      expect(@user.name).to eq "Kittie Sanchez"
    end

    it "handle resource update through the .update_attributes method" do
      @user = User.find(1)
      expect(@user.name).to eq "Tobias Fünke"
      @user.update_attributes(:name => "Lindsay Fünke")
      expect(@user.name).to eq "Lindsay Fünke"
    end

    it "handle resource update through #save on an existing resource" do
      @user = User.find(1)
      @user.name = "Lindsay Fünke"
      @user.save
      expect(@user.name).to eq "Lindsay Fünke"
    end
  end  

  context "deleting resources" do
    before do
      api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
        builder.use ActiveService::Middleware::ParseJSON
        builder.adapter :test do |stub|
          stub.get("/users/1") { |env| ok! :id => 1, :name => "Tobias Fünke", :active => true }
          stub.delete("/users/1") { |env| ok! :id => 1, :name => "Tobias Fünke", :active => false }
        end
      end

      spawn_model "User" do
        uses_api api
        attribute :name
        attribute :active
      end
    end

    it "handle resource deletion through the .destroy class method" do
      @user = User.destroy(1)
      expect(@user.active).to be_falsey
      expect(@user).to be_destroyed
    end    

    it "handle resource deletion through #destroy on an existing resource" do
      @user = User.find(1)
      @user.destroy
      expect(@user.active).to be_falsey
      expect(@user).to be_destroyed
    end
  end  

  context "customizing HTTP methods" do
    context "create" do
      before do
        api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
          builder.use Faraday::Request::UrlEncoded
          builder.use ActiveService::Middleware::ParseJSON
          builder.adapter :test do |stub|
            stub.put("/users") { |env| [200, {}, { :id => 1, :name => "Tobias Fünke" }.to_json] }
          end        
        end

        spawn_model "Foo::User" do
          uses_api api
          attribute :name
          attribute :email
          method_for :create, "PUT"
        end
      end

      after { Foo::User.method_for :create, :post }

      context "for top-level class" do
        it "uses the custom method (PUT) instead of default method (POST)" do
          user = Foo::User.new(:name => "Tobias Fünke")
          expect(user).to be_new
          expect(user.save).to be_truthy
        end
      end

      context "for children class" do
        before do
          class User < Foo::User; end
          @spawned_models << :User
        end

        it "uses the custom method (PUT) instead of default method (POST)" do
          user = User.new(:name => "Tobias Fünke")
          expect(user).to be_new
          expect(user.save).to be_truthy
        end
      end
    end

    context "update" do
      before do
        api = ActiveService::API.setup :url => "https://api.example.com" do |builder|
          builder.use ActiveService::Middleware::ParseJSON
          builder.adapter :test do |stub|
            stub.get("/users/1") { |env| [200, {}, { :id => 1, :name => "Lindsay Fünke" }.to_json] }
            stub.post("/users/1") { |env| [200, {}, { :id => 1, :name => "Tobias Fünke" }.to_json] }
          end        
        end
        
        spawn_model "User" do
          uses_api api
          attribute :name
          attribute :email
          method_for :update, :post
        end
      end

      after { User.method_for :update, :put }

      it "uses the custom method (POST) instead of default method (PUT)" do
        user = User.find(1)
        expect(user.name).to eq "Lindsay Fünke"
        user.name = "Toby Fünke"
        user.save
        expect(user.name).to eq "Tobias Fünke"
      end
    end
  end  
end
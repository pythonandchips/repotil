require 'rspec'
require 'rspec/given'
require 'pry'
require 'active_record'
require_relative '../lib/repotil'

conn = { :adapter => 'sqlite3', :database => ':memory:' }

ActiveRecord::Base.establish_connection(conn)

class TestEntity
  attr_reader :id, :name, :email
end

module DataEntities
  class TestEntity < ActiveRecord::Base
    connection.create_table :test_entities, :force => true do |t|
      t.string :name, :email, :secret_value
      t.timestamps
    end
  end
end

describe Repotil do
  before do
    DataEntities::TestEntity.delete_all
  end
  describe "when using an activerecord" do
    context "a find an entity by id" do
      Given(:repotil){ Repotil.new }
      Given(:database_record){ DataEntities::TestEntity.create(name: "hello", email: "user@local.me", secret_value: "a value") }
      Given(:klass){ TestEntity }
      When(:entity){ repotil.find(klass, database_record.id) }
      Then{ entity.should be_instance_of TestEntity  }
      Then{ entity.id.should eql database_record.id }
      Then{ entity.name.should eql database_record.name}
      Then{ entity.email.should eql database_record.email}
      Then{ entity.instance_variable_get("@secret_value").should eql database_record.secret_value}
    end

    context "when saving a new entity" do
      Given(:repotil){ Repotil.new }
      Given(:new_entity){
                     TestEntity.new.tap do |entity|
                       entity.instance_variable_set("@name", "hello")
                       entity.instance_variable_set("@email", "user@local.me")
                       entity.instance_variable_set("@secret_value", "this is a secret")
                     end
                   }
      When(:entity){ repotil.save(new_entity) }
      Then{ entity.should be_instance_of TestEntity  }
      Then{ entity.id.should_not be_nil }
      Then{ DataEntities::TestEntity.count.should eql 1}
      Then{ DataEntities::TestEntity.first.name.should eql entity.name}
      Then{ DataEntities::TestEntity.first.email.should eql entity.email}
      Then{ DataEntities::TestEntity.first.secret_value.should eql entity.instance_variable_get("@secret_value")}
      Then{ DataEntities::TestEntity.first.id.should eql entity.id}
    end

    context "when updating a already saved record" do
      Given(:repotil){ Repotil.new }
      Given(:database_record){ DataEntities::TestEntity.create(name: "hello", email: "user@local.me", secret_value: "a value") }
      Given(:saved_entity){
                     TestEntity.new.tap do |entity|
                       entity.instance_variable_set("@id", database_record.id)
                       entity.instance_variable_set("@name", "goodbye")
                       entity.instance_variable_set("@email", "admin@local.me")
                       entity.instance_variable_set("@secret_value", "this was a secret")
                     end
                   }
      When(:entity){ repotil.save(saved_entity) }
      Then{ entity.should be_instance_of TestEntity  }
      Then{ entity.id.should eql database_record.id}
      Then{ DataEntities::TestEntity.count.should eql 1}
      Then{ DataEntities::TestEntity.first.name.should eql entity.name}
      Then{ DataEntities::TestEntity.first.email.should eql entity.email}
      Then{ DataEntities::TestEntity.first.secret_value.should eql entity.instance_variable_get("@secret_value")}
      Then{ DataEntities::TestEntity.first.id.should eql entity.id}
    end
    context "when deleting an instance" do
      Given(:repotil){ Repotil.new }
      Given(:database_record){ DataEntities::TestEntity.create(name: "hello", email: "user@local.me", secret_value: "a value") }
      Given(:saved_entity){
                     TestEntity.new.tap do |entity|
                       entity.instance_variable_set("@id", database_record.id)
                       entity.instance_variable_set("@name", "goodbye")
                       entity.instance_variable_set("@email", "admin@local.me")
                       entity.instance_variable_set("@secret_value", "this was a secret")
                     end
                   }
      When(:entity){ repotil.delete(saved_entity) }
      Then{ entity.id.should eql database_record.id}
      Then{ DataEntities::TestEntity.count.should eql 0}
    end
  end
end

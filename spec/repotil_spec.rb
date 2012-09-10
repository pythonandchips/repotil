require 'rspec'
require 'rspec/given'
require 'spec_config'
require 'pry'
require 'active_record'
require_relative 'support_classes'
require_relative 'support/query_counter'
require_relative '../lib/repotil'

describe Repotil do

  before do
    DataEntities::TestEntity.delete_all
    DataEntities::AnotherTestEntity.delete_all
  end

  describe "when using an activerecord" do
    Given(:repotil){ Repotil.new }
    context "a find an entity by id" do
      Given(:database_record){ DataEntities::TestEntity.create(name: "hello", email: "user@local.me", secret_value: "a value") }
      Given(:klass){ TestEntity }
      When(:entity){ repotil.find(klass, database_record.id) }
      Then{ expect(entity).to be_instance_of TestEntity  }
      Then{ expect(entity.id).to eql database_record.id }
      Then{ expect(entity.name).to eql database_record.name}
      Then{ expect(entity.email).to eql database_record.email}
      Then{ expect(entity.instance_variable_get("@secret_value")).to eql nil}
    end

    context "when saving a new entity" do
      Given(:new_entity){
                     TestEntity.new.tap do |entity|
                       entity.instance_variable_set("@name", "hello")
                       entity.instance_variable_set("@email", "user@local.me")
                       entity.instance_variable_set("@secret_value", "this is a secret")
                     end
                   }
      When(:entity){ repotil.save(new_entity) }
      Then{ expect(entity).to be_instance_of TestEntity  }
      Then{ expect(entity.id).not_to be_nil }
      Then{ expect(DataEntities::TestEntity.count).to eql 1}
      Then{ expect(DataEntities::TestEntity.first.name).to eql entity.name}
      Then{ expect(DataEntities::TestEntity.first.email).to eql entity.email}
      Then{ expect(DataEntities::TestEntity.first.secret_value).to eql entity.instance_variable_get("@secret_value")}
      Then{ expect(DataEntities::TestEntity.first.id).to eql entity.id}
    end

    context "when updating a already saved record" do
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
      Then{ expect(entity).to be_instance_of TestEntity  }
      Then{ expect(entity.id).to eql database_record.id}
      Then{ expect(DataEntities::TestEntity.count).to eql 1}
      Then{ expect(DataEntities::TestEntity.first.name).to eql entity.name}
      Then{ expect(DataEntities::TestEntity.first.email).to eql entity.email}
      Then{ expect(DataEntities::TestEntity.first.secret_value).to eql entity.instance_variable_get("@secret_value")}
      Then{ expect(DataEntities::TestEntity.first.id).to eql entity.id}
    end

    context "when deleting an instance" do
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
      Then{ expect(entity.id).to eql database_record.id}
      Then{ expect(DataEntities::TestEntity.count).to eql 0}
    end

    context "discover type by convention" do
      Given(:database_record){ DataEntities::AnotherTestEntity.create(name: "hello", email: "user@local.me", secret_value: "a value") }
      Given(:klass){ AnotherTestEntity }
      When(:entity){ repotil.find(klass, database_record.id) }
      Then{ expect(entity).to be_instance_of AnotherTestEntity  }
    end

    context "find all instances of a class" do
      before do
        (1..3).map{ DataEntities::TestEntity.create!(name: "hello", email: "user@local.me", secret_value: "a value") }
      end
      Given(:klass){ TestEntity }
      When(:entities){ repotil.find(klass, :all) }
      Then{ expect(entities.length).to eql 3  }
      Then{ expect(entities.all?{|entity| entity.class == klass}).to be_true}
    end

    context "use finder for class" do
      Given(:user)      {DataEntities::TestEntity.create!(name: "hello", email: "user@local.me", secret_value: "a value")}
      Given(:admin)     {DataEntities::TestEntity.create!(name: "hello", email: "admin@local.me", secret_value: "a value")}
      Given(:supervisor){DataEntities::TestEntity.create!(name: "hello", email: "supervisor@local.me", secret_value: "a value")}
      Given(:klass){ TestEntity }
      When do
        user
        admin
        supervisor
      end
      When(:entity){ repotil.find(klass, :find_by_email, "user@local.me") }
      Then{ expect(entity).to be_instance_of TestEntity  }
      Then{ expect(entity.email).to eql "user@local.me"  }
    end

    context "use finder for multipule instances" do
      Given(:user)      {DataEntities::TestEntity.create!(name: "hello", email: "user@local.me", secret_value: "a value")}
      Given(:admin)     {DataEntities::TestEntity.create!(name: "hello", email: "admin@local.me", secret_value: "a value")}
      Given(:supervisor){DataEntities::TestEntity.create!(name: "hello", email: "supervisor@local.me", secret_value: "a value")}
      Given(:klass){ TestEntity }
      When do
        user
        admin
        supervisor
      end
      When(:entities){ repotil.find(klass, :find_all_by_secret_value, "a value") }
      Then{ expect(entities.length).to eql 3}
    end

    context "associations" do
      before do
        @query_counter = ActiveRecord::QueryCounter.new
        ActiveSupport::Notifications.subscribe('sql.active_record', @query_counter)
      end
      Given(:has_one_association_entity){ DataEntities::HasOneAssociationEntity.create(name: "hello", email: "user@local.me") }
      Given(:has_many_association_entity){ DataEntities::HasManyAssociationEntity.create(name: "hello", email: "user@local.me") }
      Given(:database_record){ DataEntities::TestEntity.create(name: "hello",
                                email: "user@local.me",
                                secret_value: "a value",
                                has_one_association_entity: has_one_association_entity,
                                has_many_association_entities: [has_many_association_entity]) }
      Given(:klass){ TestEntity }
      context "belongs to association" do
        context "lazy load association" do
          When(:entity){ repotil.find(klass, database_record.id) }
          Then{ expect(@query_counter.queries.grep(/SELECT (.)* FROM \"has_one_association_entities\"/).length).to eql 0 }
          context "when accessing association" do
            Then 'should query for association' do
              name = entity.has_one_association_entity.name
              expect(@query_counter.queries.grep(/SELECT (.)* FROM \"has_one_association_entities\"/).length).to eql 1
            end
          end
        end

        context "eager load association if already loaded" do
          When(:entity){ repotil.find(klass, :eager_load_association, database_record.id) }
          Then{ expect(entity.has_one_association_entity).to be_instance_of HasOneAssociationEntity}
        end
      end

      context "has many associaction" do
        context "lazy load association" do
          When(:entity){ repotil.find(klass, database_record.id) }
          Then{ expect(@query_counter.queries.grep(/SELECT (.)* FROM \"has_many_association_entities\"/).length).to eql 0 }
          context "when accessing association" do
            Then 'should query for association' do
              length = entity.has_many_association_entities.length
              expect(@query_counter.queries.grep(/SELECT (.)* FROM \"has_many_association_entities\"/).length).to eql 1
              expect(length).to eql 1
            end
          end
        end

        context "eager load association if already loaded" do
          When(:entity){ repotil.find(klass, :eager_load_association, database_record.id) }
          Then{ expect(entity.has_many_association_entities).to be_instance_of Array}
          Then{ expect(entity.has_many_association_entities.all?{|assoc| assoc.kind_of?(HasManyAssociationEntity)}).to be_true}
        end
      end
    end
  end
end

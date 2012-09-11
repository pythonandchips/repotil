require 'rspec'
require 'rspec/given'
require 'spec_config'
require 'pry'
require 'active_record'
require_relative '../support_classes'
require_relative '../../lib/repotil'

describe Repotil::HasManyAssociationProxy do
  describe "iterating over returned results" do
    Given(:has_many_association_entity){ DataEntities::HasManyAssociationEntity.create(name: "hello", email: "user@local.me") }
    Given(:database_record){ DataEntities::TestEntity.create(name: "hello",
                              email: "user@local.me",
                              secret_value: "a value",
                              has_many_association_entities: [has_many_association_entity])
                            }
    Given(:klass){ TestEntity }
    Given(:association_class){ HasManyAssociationEntity }
    Given(:association){ database_record.association(:has_many_association_entities).reflection }
    Given(:association_proxy){ Repotil::HasManyAssociationProxy.new(database_record.id, association, association_class )  }
    When(:entities) do
      entities = []
      association_proxy.each do |entity|
        entities << entity
      end
      entities
    end
    Then{ expect(entities.length).to eql 1 }
    Then{ expect(entities.all?{|entity| entity.class == HasManyAssociationEntity}).to be_true}
    Then{ expect(entities.first.email).to eql "user@local.me" }
    context "using enumerable functions" do
      When(:names){association_proxy.map{|entity| entity.name }}
      Then{ expect(names).to eql ["hello"] }
    end
    context "when using array functions" do
      context "accessing index" do
        When(:entity){association_proxy[0]}
        Then{ expect(entity.name).to eql "hello" }
      end

      context "adding item" do
        When{association_proxy << HasManyAssociationEntity.new }
        Then{ expect(association_proxy.length).to eql 2 }
      end
    end
  end
end

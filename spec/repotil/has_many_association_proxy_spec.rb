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

  end

end

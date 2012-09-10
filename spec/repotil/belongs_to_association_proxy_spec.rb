require 'rspec'
require 'rspec/given'
require 'spec_config'
require 'pry'
require 'active_record'
require_relative '../support_classes'
require_relative '../../lib/repotil'

describe Repotil::BelongsToAssociationProxy do
  context "when association is belongs to" do
    context "it should return act like the associated entity" do
      Given(:has_one_association_entity){ DataEntities::HasOneAssociationEntity.create(name: "hello", email: "user@local.me") }
      Given(:database_record){ DataEntities::TestEntity.create(name: "hello",
                                email: "user@local.me",
                                secret_value: "a value",
                                has_one_association_entity: has_one_association_entity)
                              }
      Given(:klass){ TestEntity }
      Given(:association_class){ HasOneAssociationEntity }
      Given(:association){ database_record.association(:has_one_association_entity) }
      Given(:association_proxy){ Repotil::BelongsToAssociationProxy.new(has_one_association_entity.id, association, association_class )  }
      Then{ expect(association_proxy.name).to eql has_one_association_entity.name  }
      Then{ expect(association_proxy.email).to eql has_one_association_entity.email }
      Then{ expect(association_proxy.respond_to?(:name)).to be_true }
      Then{ expect(association_proxy.class).to eql HasOneAssociationEntity }

      context "should allow setting of variables" do
        When { association_proxy.email = "another@local.me" }
        Then { expect(association_proxy.email).to eql "another@local.me" }
      end

      context "should allow calling of methods with params" do
        When(:method_result){ association_proxy.add_numbers(1, 2, 3) }
        Then { expect(method_result).to eql 6 }
      end

      context "should allow blocks to be passed to object" do
        When(:block_result){ association_proxy.run_block{"whoo_hoo"} }
        Then { expect(block_result).to eql "whoo_hoo" }
      end
    end
  end
end

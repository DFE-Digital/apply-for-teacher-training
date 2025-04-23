module FactorySpecHelpers
  def factory(name, &)
    describe("factory :#{name}") do
      let(:factory) { name }

      instance_eval(&)
    end
  end

  def trait(name, aliased_to: nil, &)
    if aliased_to
      describe("trait :#{name}") do
        let(:traits) { [name] }

        it_behaves_like("trait :#{aliased_to}")
      end
    else
      shared_examples("trait :#{name}", &)
      describe("trait :#{name}") do
        let(:traits) { [name] }

        it_behaves_like("trait :#{name}")
      end
    end
  end

  def field(name, presence: true, type: nil, value: nil, one_of: nil, matches: nil)
    if !value.nil?
      it "sets `#{name}` to `#{value}`" do
        expect(record.public_send(name)).to eq(value)
      end
    elsif one_of
      it "sets `#{name}` to one of `#{one_of}`" do
        expect(one_of).to include(record.public_send(name))
      end
    elsif matches
      it "sets `#{name}` to match `#{matches}`" do
        expect(record.public_send(name)).to match(matches)
      end
    elsif type
      it "sets `#{name}` to a(n) `#{type}`" do
        expect(record.public_send(name)).to be_a(type)
      end
    elsif presence
      it "sets `#{name}`" do
        expect(record.public_send(name)).to be_present
      end
    else
      it "sets `#{name}` to nil" do
        expect(record.public_send(name)).to be_nil
      end
    end
  end
end

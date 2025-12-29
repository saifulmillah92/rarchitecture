# frozen_string_literal: true

require "spec_helper"

RSpec.describe RArchitecture::ApplicationInput do
  before do
    @params = {
      email: "saiful@example.com",
      role: "admin",
      address: {
        street: "123 Main St",
        city: "Anytown",
        zip_code: "12345",
        country: {
          name: "Nevada",
          code: "NV",
        },
      },
    }
  end

  context "with String validation" do
    it "fallback to default value when state is not given" do
      input = StringInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.state).to eq("active")
    end

    it "returns error when state is not in expected values" do
      @params[:state] = "invalid"
      input = StringInput.new(@params)

      expect(input.valid?).to be(false)
      message = input.errors.full_messages.first
      expect(message).to eq("State invalid value: must be one of active, inactive")
    end

    it "returns error when role is invalid value" do
      @params[:role] = "invalid"
      input = StringInput.new(@params)

      expect(input.valid?).to be(false)
      message = input.errors.full_messages.first
      expect(message).to eq("Role invalid value: must be one of admin, user")
    end

    it "returns error when role null as allow_blank is false as default" do
      @params[:role] = nil
      input = StringInput.new(@params)

      expect(input.valid?).to be(false)
      message = input.errors.full_messages.first
      expect(message).to eq("Role must be a string")
    end

    it "returns error when initials length is greater than max" do
      @params[:initials] = "SMLL"
      input = StringInput.new(@params)

      expect(input.valid?).to be(false)
      message = input.errors.full_messages.first
      expect(message).to eq("Initials is too long (maximum is 3 characters)")
    end

    it "returns error when initials length is less than min" do
      @params[:initials] = "S"
      input = StringInput.new(@params)

      expect(input.valid?).to be(false)
      message = input.errors.full_messages.first
      expect(message).to eq("Initials is too short (minimum is 2 characters)")
    end

    it "returns ok when initials length is greater than min and less than max" do
      @params[:initials] = "SM"
      input = StringInput.new(@params)

      expect(input.valid?).to be(true)
    end

    it "sets name to default value if value is not given" do
      input = StringInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.name).to eq("Saiful")
    end

    it "sets name to current value if value is given" do
      @params[:name] = "John Doe"
      input = StringInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.name).to eq("John Doe")
    end

    context "with custom error message" do
      it "returns error when email is not valid regex" do
        @params[:email] = "John Doe"
        input = StringInputWithCustomError.new(@params)

        expect(input.valid?).to be(false)
        message = input.errors.full_messages.first
        expect(message).to eq("Email format tidak benar")
      end

      it "returns custom error message when name is set to Array" do
        @params[:name] = ["John Doe"]
        input = StringInputWithCustomError.new(@params)

        expect(input.valid?).to be(false)
        message = input.errors.full_messages.first
        expect(message).to eq("Tipe data nama tidak benar")
      end

      it "returns custom error message when intials is too short" do
        @params[:initials] = "J"
        input = StringInputWithCustomError.new(@params)

        expect(input.valid?).to be(false)
        message = input.errors.full_messages.first
        expect(message).to eq("Initial minimal 2 karakter")
      end

      it "returns custom error message when intials is too long" do
        @params[:initials] = "JohnDoe"
        input = StringInputWithCustomError.new(@params)

        expect(input.valid?).to be(false)
        message = input.errors.full_messages.first
        expect(message).to eq("Initial maximal 2 karakter")
      end

      it "returns custom error message when street is blank" do
        @params[:address][:street] = nil
        input = StringInputWithCustomError.new(@params)

        expect(input.valid?).to be(false)
        message = input.errors.full_messages.first
        expect(message).to eq("Address Street harus di isi")
      end
    end
  end

  context "with Number validation" do
    it "returns error when phone length is greater than max" do
      @params[:phone] = 865_645_735_453_745
      input = NumberInput.new(@params)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Phone is too long (maximum is 13 digits)")
    end

    it "returns error when initials length is less than min" do
      @params[:phone] = 865_64
      input = NumberInput.new(@params)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Phone is too short (minimum is 8 digits)")
    end

    it "returns ok when initials length is greater than min and less than max" do
      @params[:phone] = 851_111_111
      input = NumberInput.new(@params)

      expect(input.valid?).to be(true)
    end

    it "sets code to default value if value is not given" do
      input = NumberInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.code).to eq("+62")
    end

    it "sets code to current value if value is given" do
      @params[:code] = "+77"
      input = NumberInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.code).to eq("+77")
    end

    context "with custom error message" do
      it "returns custom error message when phone is blank" do
        @params[:phone] = nil
        input = NumberInputValidation.new(@params)

        expect(input.valid?).to be(false)
        message = input.errors.full_messages.first
        expect(message).to eq("Phone harus di isi")
      end

      it "returns custom error message when phone is too short" do
        @params[:phone] = 861
        input = NumberInputValidation.new(@params)

        expect(input.valid?).to be(false)
        message = input.errors.full_messages.first
        expect(message).to eq("Phone minimal 8 digit")
      end

      it "returns custom error message when phone is too long" do
        @params[:phone] = 861_987_098_111_222
        input = NumberInputValidation.new(@params)

        expect(input.valid?).to be(false)
        message = input.errors.full_messages.first
        expect(message).to eq("Phone maksimal 13 digit")
      end
    end
  end

  context "with Array validation" do
    it "sets tags to default value" do
      input = ArrayInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.tags).to eq(["tag 1"])
    end

    it "returns error when tags is not an array value" do
      @params[:tags] = "invalid"
      input = ArrayInput.new(@params)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Tags must be a array")
    end

    it "returns ok when when is an array" do
      @params[:tags] = ["Tag 1", "Tag 2"]
      input = ArrayInput.new(@params)

      expect(input.valid?).to be(true)
    end

    it "returns error when products is not a hash collection" do
      @params[:products] = ["Tag 1", "Tag 2"]
      input = ArrayInput.new(@params)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Products[0] must be a hash")
    end

    it "returns ok when products is a hash collection" do
      @params[:products] = [{ id: 1 }]
      input = ArrayInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.products[0].id).to eq(1)
    end

    context "with custom error message" do
      before do
        @klass = ArrayInput
        @klass.class_eval do
          optional(:array_values).array(format: { message: "Tipe data `array values` harus Array" })
        end
      end

      it "returns valid error message" do
        @params[:array_values] = "Invalid"
        input = @klass.new(@params)

        expect(input.valid?).to be(false)
        expect(input.errors.full_messages.first).to eq("Tipe data `array values` harus Array")
      end

      it "returns valid error message when blank" do
        @params[:array_values] = nil
        input = @klass.new(@params)

        expect(input.valid?).to be(false)
        expect(input.errors.full_messages.first).to eq("Tipe data `array values` harus Array")
      end
    end
  end

  context "with Hash validation" do
    it "returns error when address is not a hash" do
      @params[:address] = "invalid"
      input = HashInput.new(@params)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Address must be a hash")
    end

    it "returns ok when address is valid" do
      input = HashInput.new(@params)

      expect(input.valid?).to be(true)
    end

    context "with custom error message" do
      before do
        @klass = HashInput
        @klass.class_eval do
          optional(:address2).hash(format: { message: "Tipe data `address2` harus Hash" })
        end
      end

      it "returns valid error message" do
        @params[:address2] = "Invalid"
        input = @klass.new(@params)

        expect(input.valid?).to be(false)
        expect(input.errors.full_messages.first).to eq("Tipe data `address2` harus Hash")
      end

      it "returns error when address2 is blank" do
        @params[:address2] = nil
        input = @klass.new(@params)

        expect(input.valid?).to be(false)
        expect(input.errors.full_messages.first).to eq("Tipe data `address2` harus Hash")
      end
    end
  end

  context "with Bool validation" do
    it "sets active to default value if value is not given" do
      input = BoolInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.active).to be(true)
    end

    it "sets active to current value if value is given" do
      @params[:active] = "false"
      input = BoolInput.new(@params)

      expect(input.valid?).to be(true)
      expect(input.active).to eq("false")
    end

    it "returns error when active is not a valid type value" do
      @params[:active] = "string"
      input = BoolInput.new(@params)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Active must be boolean")
    end

    context "with custom error message" do
      it "returns correct message" do
        @params[:is_active] = "string"
        klass = BoolInput
        klass.class_eval do
          optional(:is_active).bool(format: { message: "Tipe data `active` harus boolean" })
        end

        input = klass.new(@params)

        expect(input.valid?).to be(false)
        expect(input.errors.full_messages.first).to eq("Tipe data `active` harus boolean")
      end
    end
  end

  context "with ApplicationInput" do
    it "strips unknown attributes except model attributes" do
      input = described_class.new(@params, model: User)

      expect(input.output.keys).to include(:email)
      expect(input.output.keys).not_to include(:address)
    end

    it "validates model attributes" do
      @params[:email] = ""
      input = described_class.new(@params, model: User)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Email can't be blank")
    end
  end

  context "with UserCreationInput" do
    it "validates email domain" do
      @params[:email] = "saiful@invalid.com"
      input = UserCreationInput.new(@params.slice(:email))

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Email must be from example.com domain")
    end

    it "validates presence of required email" do
      @params[:email] = nil
      input = UserCreationInput.new(@params.slice(:email))

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Email can't be blank")
    end

    it "validates presence of required street" do
      @params[:address][:street] = nil
      input = UserCreationInput.new(@params)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Address street can't be blank")
    end

    it "validates presence of required country name" do
      @params[:address][:country][:name] = nil
      input = UserCreationInput.new(@params)

      expect(input.valid?).to be(false)
      expect(input.errors.full_messages.first).to eq("Address country name can't be blank")
    end

    it "passes validation for valid input" do
      input = UserCreationInput.new(@params.slice(:email))
      expect(input.valid?).to be true
    end

    it "supports nested attribute accessors" do
      input = UserCreationInput.new(@params)
      expect(input.address).to be_a(Object)
    end

    it "transforms input data key DSL" do
      input = UserCreationInput.new(@params)

      expect(input.output.keys).to include(:address_attributes)
      expect(input.output[:address_attributes].keys).to include(:country_attributes)
    end

    it "strips unknown attributes and ensure the inherited works as expected" do
      expect(@params).to have_key(:role)

      input = UserCreationInput.new(@params)
      expect(input.output).not_to have_key(:role)
    end
  end
end

class StringInput
  include ::Input

  optional(:name).string(default: "Saiful")
  optional(:initials).string(length: { minimum: 2, maximum: 3 }, format: { allow_blank: true })
  optional(:state).any_of(["active", "inactive"], default: "active")
  optional(:role).any_of(["admin", "user"])
end

class StringInputWithCustomError
  include ::Input

  optional(:email).string(
    format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "Email format tidak benar" },
  )
  optional(:first_name).string(format: { allow_blank: true })
  optional(:name).string(
    default: "Saiful",
    format: { allow_blank: true, message: "Tipe data nama tidak benar" },
  )
  optional(:initials).string(
    length: {
      minimum: 2,
      maximum: 3,
      too_short: "Initial minimal 2 karakter",
      too_long: "Initial maximal 2 karakter",
    },
    format: { allow_blank: true },
  )
  optional(:state).string(any_of: ["active", "inactive"], default: "active")
  optional(:role).any_of(["admin", "user"])

  optional(:address).hash do
    optional(:street).string(format: { message: "Street harus di isi" })
  end
end

class NumberInput
  include ::Input

  optional(:code).string(default: "+62")
  optional(:phone).number(
    format: { allow_blank: true },
    length: {
      minimum: 8,
      maximum: 13,
    },
  )
end

class NumberInputValidation
  include ::Input

  optional(:phone).number(
    format: { message: "Phone harus di isi" },
    length: {
      minimum: 8,
      maximum: 13,
      too_short: "Phone minimal 8 digit",
      too_long: "Phone maksimal 13 digit",
    },
  )
end

class ArrayInput
  include ::Input

  optional(:tags).array(default: ["tag 1"])
  optional(:products).array(format: { allow_blank: true }) do
    required(:id).number
  end
end

class HashInput
  include ::Input

  optional(:address).hash do
    required(:street).string
    optional(:city).string
  end
end

class BoolInput
  include ::Input

  optional(:active).bool(default: true)
end

## 🚀 Quick Start

Get up and running in minutes:

#### 1. Add the gem to your application's `Gemfile`:
```ruby
gem "rarchitecture", git: "https://github.com/saifulmillah92/rarchitecture"
```

#### 2. Install:
```bash
bundle install
```

#### 3. Initialize the base architecture:
```bash
rails generate rarchitecture:init --view
```
- This creates shared base layers:
- Repositories, Services, Inputs, Outputs
- Exceptions
- Base View controllers (modified)

#### 4. Scaffold a `User` controller:
```bash
rails g rarchitecture:controller:view User
```
##### - Output:
```bash
create  app/controllers/users_controller.rb
create  app/views/users/index.html.erb
create  app/views/users/new.html.erb
create  app/views/users/edit.html.erb
insert  config/routes.rb
```

##### - 🎉 Endpoint generated successfully!
Test it instantly:
```bash
curl -X GET http://localhost:3000/users
```

Now simply run the server and start `CRUD` operations on `User`. 🎉🎉🎉

# About Rarchitecture Gem
`Rarchitecture` is a lightweight architectural layer for Ruby on Rails that introduces clean, maintainable patterns for building scalable applications.

It provides reusable base classes and generators for **Controller**, **Exception**, **Input**, **Output**, **Repository**, and **Service** layers — each with inline documentation and usage guides.

`Rarchitecture` supports two controller styles:
- **View Controllers** for server-rendered HTML pages
- **API Controllers** for JSON-based APIs

Both share the same service, input, repository, and output layers.

---
## Why Rarchitecture?
designed for teams that want:
- Predictable Rails structure
- Clear separation of concerns
- Minimal controller logic
- Scalable patterns without overengineering

## Compatibility
`Rarchitecture` is tested with:
- Ruby 3.3.x
- Rails 8.1.x

Other versions may work, but these are the officially supported versions.

## 📦 What This Gem Provides

## 1. ApplicationController (View)
Base controller for all HTML (view-based) endpoints.
Inherits from `Rarchitecture::ApplicationController::VIEW`.
This controller provides a standard CRUD flow for server-rendered views and is intended for admin panels, internal tools, or simple HTML pages.

### Features:
- Standard CRUD actions (index, new, edit, show, create, update, destroy)
- Automatic service delegation (service)
- Strong parameter handling (permitted_params)
- Input validation (validate!)
- Centralized error handling
- Default redirects for create, update, and destroy
- Shared helpers for view rendering

### Stubbed methods:
```ruby
  def service
    raise ApplicationService::NotImplementedError, "service not implemented"
  end
```

### 🛠 View Controller Generator

#### Command:
```bash
rails g rarchitecture:controller:view User
```

#### This creates:
```pgsql
create  app/controllers/users_controller.rb
create  app/views/users/index.html.erb
create  app/views/users/new.html.erb
create  app/views/users/edit.html.erb
insert  config/routes.rb
```

#### What’s Included:
- `UsersController` inheriting from `ApplicationController`
- CRUD actions provided by the base controller (no boilerplate code)
- Prebuilt CRUD views (`index`, `new`, `edit`)
- RESTful routes (`resources :users`)
- Automatic service and output delegation (`service`, `output`)
- Ability to disable actions via undef_action

No CRUD logic is written in the controller —
all behavior is inherited from the base VIEW controller.

## 2. Api::ApplicationController (API)
Base controller for all API endpoints under the Api namespace.
Inherits from `Rarchitecture::ApplicationController::API`.

### Features:
- Centralized error handling (rescue_from StandardError with JSON output)
- Standard RESTful actions (index, show, create, update, destroy)
- Input validation (permitted_params, validate!)
- Service layer delegation (service, model, query_params)
- Output formatting (output, default_output, render_json, render_json_array, render_error, render_empty_json)
- Authorization helpers (authorize!)
- Logging and failure capture (log_error, halt!)
- Pagination helpers (limit, offset, current_page, total count)

### Stubbed methods:
```ruby
  def service
    raise ApplicationService::NotImplementedError, "service not implemented"
  end
```

### 🛠 API Controller Generator
Generates a JSON API controller under the Api namespace.

#### Command:
```bash
rails g rarchitecture:controller:api User
```

#### This creates:
```pgsql
create  app/controllers/api/users_controller.rb
insert  config/routes.rb
```

#### What’s Included:
- `Api::UsersController` inheriting from `Api::ApplicationController`
- Standard RESTful API actions (`index`, `show`, `create`, `update`, `destroy`)
- JSON rendering handled by the base API controller
- Automatic service delegation (`service`)
- Ability to disable endpoints via undef_action

No CRUD logic is written in the controller —
all behavior is inherited from the base API controller.

## 3. ApplicationInput
Facade for request parameter validation and normalization.
Inherits from `Rarchitecture::ApplicationInput`.

### Example: AddressCreationInput:
```ruby
  class AddressCreationInput < ApplicationInput
    required(:street).string              # street must be present and a string
    optional(:city).string                # optional string field
    optional(:zip_code).string            # optional string field
    optional(:country).hash do            # nested hash for country
      required(:name).string              # country name required
      optional(:code).string              # optional country code
    end

    transform_key(country: :country_attributes) # renames :country to :country_attributes in output
  end
```

### Example: UserCreationInput
```ruby
  class UserCreationInput < ApplicationInput
    required(:email).string                           # email must be present and a string
    optional(:address).hash(from: AddressInput)       # nested input using AddressInput

    transform_key(address: :address_attributes)       # renames :address to :address_attributes

    validate :check_email_domain                      # custom validation hook

    private

    def check_email_domain
      return unless email
      return if email.end_with?('@example.com')

      errors.add(:email, 'must be from example.com domain')
    end
  end
```

### Key Points

- `required(:field)` → enforces presence and type.
- `optional(:field)` → allows field but not mandatory.
- `.hash(from: OtherInput)` → nests another input class for structured validation.
- `transform_key` → renames keys in the normalized output (e.g. Rails convention *_attributes).
- `validate :method_name` → adds custom validation logic beyond type checks.

### Example Output
```ruby
  UserCreationInput.new({ email: "saiful@gmail.com", address: { street: "Bogor" }}).output
  # => { email: "saiful@gmail.com", address_attributes: { street: "Bogor" } }
```

### Validation Types

Available validation types are:
- `.string` → enforces the value must be a string.
- `.bool` → enforces the value must be a boolean (true/false).
- `.array` → enforces the value must be an array.
- `.hash` → enforces the value must be a hash (nested structure).

### Default Values

You can also set default values for inputs.
For example:
```ruby
  optional(:status).string(default: "active")
  # If no :status is provided, it will default to "active"
```

This works across types `(.string, .bool, .array)` to ensure predictable outputs even when inputs are missing.

### 🛠 Input Generator
Generates input objects for validating and normalizing request parameters.

#### Command:
```bash
rails g rarchitecture:input User
```

#### This creates:
```bash
create  app/inputs/user_creation_input.rb
create  app/inputs/user_update_input.rb
```

#### What’s Included:
- `UserCreationInput` for create actions
- `UserUpdateInput` for update actions
- Attribute definitions based on model columns
- Required and optional field validation

#### 📚 Usage Examples
1. Missing required field → invalid
```ruby
  params = { name: "saiful" }
  input = UserCreationInput.new(params)

  input.valid? # => false
  input.errors.full_messages
  # => ["Email can't be blank"]
```

2. All required fields present → valid
```ruby
  params = { email: "saiful@gmail.com", name: "saiful" }
  input = UserCreationInput.new(params)

  input.valid? # => true
  input[:email] # => "saiful@gmail.com"
  input[:name]  # => "saiful"

  input.output
  # => {:email=>"saiful@gmail.com", :name=>"saiful"}
```

#### Notes:
- Any parameter not explicitly declared is discarded
- required fields must be present or validation fails
- Inputs are used by controllers to validate incoming data before calling services

## 4. ApplicationService
Encapsulates business logic, CRUD operations, validation helpers, and transaction patterns.
Inherits from `Rarchitecture::ApplicationService`.

### Initialization:
```ruby
  service = ApplicationService.new(
    model: User,          # ActiveRecord model class
    user: current_user,   # optional, current user context
    repository: UserRepository.new  # optional, custom repository for persistence
  )
```

#### Example usage:
```ruby
  # Example usage of ApplicationService
  service = ApplicationService.new(model: User)

  # Fetch all users
  service.all
  # => returns all User records limited by 10

  # Fetch users filtered by name
  service.all(name: "saiful")
  # => returns users where name = "saiful"

  # Fetch users sorted by id ascending
  service.all(sort_column: "id", sort_direction: "asc")
  # => returns users ordered by id ASC

  # Fetch limited number of users
  service.all(limit: 5)
  # => returns only 5 users

  # Fetch users with includes associations
  service.all(includes: [:address])
  # => returns users and preloading the associations

  # Find a single user by primary key
  service.find(1)
  # => returns the User with id = 1

  # Create a new user with given attributes
  service.create(email: "alice@gmail.com")
  # => inserts a new User record with email "alice@gmail.com"

  # Update an existing user by id
  service.update(1, name: "Bob")
  # => updates the User with id = 1, setting name = "Bob"

  # Destroy (delete) a user by id
  service.destroy(1)
  # => deletes the User with id = 1
```

### Validation Helpers
- `validate!(input)`
  - Ensures an ActiveRecord model is valid. Raises RecordInvalid if validation fails, otherwise returns the record.
- `assert!(*truths, on_error: "Invalid")`
  - Checks one or more conditions. Raises Invalid if none are truthy.
- `authorize!(*truths, on_error: "Not allowed")`
  - Enforces permission checks. Raises Unauthorized if none are truthy.

### 🛠 Service Generator
Generates a service object for encapsulating business logic.

#### Command:
```bash
rails g rarchitecture:service User
```

#### This creates:
```bash
create  app/services/user_service.rb
```

Custom service example:
```ruby
  class UserService < ApplicationService
    def initialize(user: nil)
      super(model: User, user: user, repository: UserRepository.new)
    end

    def create(attrs = {})
      assert! !model.exists?(email: attrs[:email]), on_error: "Email already taken"
      super
    end
  end

  service = UserService.new # optionally accepts a user context
  service.create(email: "alice@gmail.com")
  # => `create': Email already taken (Rarchitecture::ApplicationService::Invalid)
```

#### Notes:
- Services coordinate repositories, validations, and business rules
- CRUD operations are inherited from ApplicationService
- Custom logic can be added by overriding methods (create, update, etc.)
- Services can optionally receive the current user for authorization or auditing
- Inputs are responsible for validating request parameters.
- Services should only validate business rules or invariants.
- Avoid duplicating parameter validation in services.

## 5. ApplicationRepository
Encapsulates query logic, ordering, filtering, and associations.
Inherits from `Rarchitecture::ApplicationRepository`.

#### Usage:
```ruby
  repo = ApplicationRepository.new(User.all)
  repo = repo.filter(email: "saiful@gmail.com")
  repo = repo.include(:address)
  repo.to_a
  # User Load (0.7ms)  SELECT "users".* FROM "users" WHERE (LOWER(users.email) = 'saiful@gmail.com') ORDER BY "users"."id" DESC /*application='TestGemfile'*/
  # =>
  # [#<User:0x00007fbb888c9600
  #   id: 1,
  #   email: "[FILTERED]",
  #   name: "saiful",
  #   created_at: "2025-12-20 12:52:08.017712000 +0000",
  #   updated_at: "2025-12-20 12:52:08.017712000 +0000">]
```

### Built‑in Filters

These filters provide a consistent way to handle search, sorting, and pagination across repositories.
- `filter_by_q` → applies a free‑text search query.
- `filter_by_limit` → restricts the number of records returned.
- `filter_by_offset` → skips a given number of records (offset‑based pagination).
- `filter_by_sort_column` → specifies which column to sort results by.
- `filter_by_sort_direction` → defines the sort order (asc or desc).
- `filter_by_page` → enables page‑based pagination.
- `filter_by_{column_name}` → automatically generates filters for each column in the table (e.g. filter_by_email, filter_by_name).

### Notes
- All filter methods can be overridden in subclasses to customize behavior.
- This makes it easy to adapt filtering logic to specific models or business rules while keeping a consistent interface.

### Example Usage
Keyword search with sorting:
```ruby
  repo = ApplicationRepository.new(User.all)
  repo.filter(q: "saiful", sort_column: "name", sort_direction: "desc")
```
Applies a keyword search for "saiful", sorts by the name column, and orders results in descending direction.

### Page vs. Offset
Under the hood, page‑based and offset‑based pagination work the same way. Both ultimately calculate an OFFSET and LIMIT for the query:
- `Offset‑based` → you pass offset directly.
- `Page‑based` → the system converts page and limit into an equivalent offset (offset = (page - 1) * limit).
So these two examples are equivalent:
```ruby
# Page-based
repo.filter(page: 2, limit: 10)

# Offset-based
repo.filter(offset: 10, limit: 10)
```
Both will skip the first 10 records and return the next 10

### 🛠 Repository Generator
Generates a repository for encapsulating query logic for a model.

#### Command:
```bash
rails g rarchitecture:repository User
```

#### This creates:
```bash
create  app/repositories/user_repository.rb
```

#### Notes:
- default_scope defines the base ActiveRecord relation
- All filtering, sorting, and pagination are applied on top of this scope
- Custom query logic should live in the repository, not in controllers or services

#### Custom scope example:
```ruby
  class UserRepository < ApplicationRepository
    def default_scope
      User.all
    end

    def filter_by_street_address(street)
      @scope.joins(:address).where(addresses: { street: street })
    end
  end

  UserRepository.new.filter(street_address: "bogor").to_a
```

## 6. ApplicationOutput
Specialized response wrapper for API responses.
Provides consistent JSON structure with status codes, messages, and a root key (:data).

#### 👉 Note:
While designed for API responses, `ApplicationOutput` can also be used in Rails views or other layers where a consistent data wrapper is helpful. Because it supports `.as_struct`, you can easily work with structured objects in templates or service layers.

#### Usage:
```ruby
  ApplicationOutput.new(user).root_json
  # => { code: 200, message: "ok", data: { id: 1, email: "..." } }

  ApplicationOutput.array(users, limit: 10, offset: 0, total: 20).root_json
  # => { code: 200, message: "ok", data: [{ id: 1, email: "..." }] }
```

Pagination examples:
- `Offset-based`: includes limit, current_offset, next_offset, prev_offset
- `Page-based`: includes pagination hash with current_page, total_pages

### Additional Methods
- `.to_json`
  - Returns the raw JSON string representation of the object. Useful for API responses or logging.

```ruby
  ApplicationOutput.new(user).to_json
  # => "{\"id\":70,\"email\":\"administrator@default.com\",\"name\":\"rename name\",\"created_at\":\"2026-01-02T03:04:43.306Z\",\"updated_at\":\"2026-01-02T13:07:54.161Z\"}"
```

- `.as_json`
  - Returns the Ruby hash representation of the object. Handy for controllers or view helpers.

```ruby
  ApplicationOutput.new(user).as_json
  # => {
  #   "id"=>70,
  #   "email"=>"administrator@default.com",
  #   "name"=>"rename name",
  #   "created_at"=>"2026-01-02T03:04:43.306Z",
  #   "updated_at"=>"2026-01-02T13:07:54.161Z"
  # }
```

- `.as_struct`
  - Returns the object wrapped as a Ruby `Struct`. This makes it convenient to use in views or service objects where dot-notation feels cleaner than hash access.

```ruby
  ApplicationOutput.new(user).as_struct
  # => #<struct
  #  id=70,
  #  email="administrator@default.com",
  #  name="rename name",
  #  created_at="2026-01-02T03:04:43.306Z",
  #  updated_at="2026-01-02T13:07:54.161Z">
```

### When to Use
- `API responses` → root_json or to_json
- `Rails views / helpers` → as_json or as_struct for clean access
- `Logging / debugging` → to_json for raw string output

### 🛠 Output Generator
Generates an output class for formatting API responses.

#### Command:
```bash
  rails g rarchitecture:output User
```

#### This creates:
```bash
create  app/outputs/user_output.rb
```

#### What’s Included:
- UserOutput inheriting from ApplicationOutput
- Default JSON response structure (code, message, data)
- Support for custom output formats

#### Custom output example:
```ruby
  class UserOutput < ApplicationOutput
    def mini_format
      { email: @object.email }
    end
  end

  # single object
  UserOutput.new(user, use: :mini_format).root_json
  # => {:code=>200, :message=>"OK", "data"=>{"email"=>"saiful@gmail.com"}}

  # Array data with Offset-based
  UserOutput.array(users, use: :mini_format, total: 1, limit: 10, offset: 0).root_json
  # =>
  # {"code"=>200,
  # "message"=>"OK",
  # "data"=>[{"email"=>"saiful@gmail.com"}],
  # "limit"=>10,
  # "current_offset"=>0,
  # "next_offset"=>10,
  # "prev_offset"=>0}

  # Array data with Page-based
  UserOutput.array(users, use: :mini_format, total: 1, limit: 10, current_page: 1).root_json
  # =>
  # {"code"=>200,
  # "message"=>"OK",
  # "data"=>[{"email"=>"saiful@gmail.com"}],
  # "pagination"=>{"current_page"=>1, "next_page"=>nil, "prev_page"=>nil, "total_pages"=>1}}
```

Default Behavior
If no custom methods are defined:
- Output will fallback to:

```ruby
@object.as_json
```
- Output will automatically return the result (or object) as-is.

#### This means:
- You can start with zero methods
- Add formats only when needed
- No boilerplate required for simple resources

## 8. Generators

### Initialize Base Architecture
```bash
rails generate rarchitecture:init
```

Creates the shared base layers:
- Repositories, Services, Inputs, Outputs
- Exceptions
- Base API and View controllers

### Scaffold Full Architecture for a Model
```bash
  rails generate rarchitecture:arc User
```

Generates:
- Repository and Service
- Inputs (create & update)
- Output
- API Controller
- View Controller with views (`index`, `new`, `edit`)
- Routes

### Controller Generation Options
You may control which controller is generated using the following options:

```bash
rails generate rarchitecture:arc User --api
```

Generates:
- All base layers
- API Controller only

```bash
rails generate rarchitecture:arc User --view
```

Generates:
- All base layers
- View Controller only

### Interactive Mode
If no controller option is provided, the generator will prompt you to choose:

```bash
Which controller do you want to generate? (api/view/both)
```

Available options:
- api
- view
- both

This ensures the generator always has an explicit intent when creating controllers.

## 9. 🛠 Development & Testing

We maintain high code quality through a comprehensive RSpec suite that covers the core logic and generators of the `rarchitecture` gem.

### Internal Gem Specs
If you are contributing to this gem or verifying its stability, you can run the internal test suite which covers:

- **Core Components:** Logic for `Inputs`, `Outputs`, and `ModelCollections`.
- **Generators:** Functional tests for `rarchitecture:init` and `rarchitecture:arc` to ensure files are generated correctly across different modes (`--api`, `--view`).
- **Mocking System:** Verification of the in-memory repository and model mocks used for testing.

### Running the Suite
First, ensure you have all dependencies installed:

```bash
bundle install
```

Then, run the full suite:
```bash
bundle exec rspec
```

Our generator specs use a dedicated tmp directory and a mocked Rails environment to ensure that testing the scaffolding process does not interfere with your local development environment.

## 🧭 Architectural Guidelines
- Use `init` once to set up the architecture
- Use `arc` to scaffold everything for a model
- Or generate only what you need, when you need it

### Keep:
- Query logic in Repositories
- Business rules in Services
- Validation in Inputs
- Formatting in Outputs
- Orchestration in Controllers

## 🎉 Final Note
When components are successfully generated, you’ll see:

```
🎉  Congratulations! Your Rarchitecture components have been successfully generated.
You are now ready to begin using them.
```

## 🔄 Request Flow

1. **Controller** receives the request and delegates to the service.
2. **Input** validates and normalizes parameters in controller.
3. **Service** executes business logic and orchestrates repositories.
4. **Repository** encapsulates query logic and database interactions.
5. **Output** formats the data into structured output and wraps responses with consistent JSON and pagination.

#Carnival
By [Vizir](http://vizir.com.br/).

![Vizir Logo](http://vizir.com.br/wp-content/themes/vizir/images/logo.png)

Carnival is an easy-to-use and extensible Rails Engine to speed up the development of data management interfaces.

When you use Carnival you can benefit from made features that are already done. If you need to change anything, you can write your own version of the method, using real Ruby code without worrying about the syntax of the engine.

##Features

* Easy way to CRUD any data;
* Search data easily;
* Advanced searches in a minute. You can specify which fields you want to search for;
* Fancy time filter, based on Toggl design;
* Authentication and CRUD of users based on Devise;
* Facebook and Google authentication;
* Nice default layout, ready to use.
* User notification engine.
* New and Edit forms are easily configured. If you do ot like, you can write your own views.

##Based of the Gems we are used to
* Devise for authentication;
* OmniAuth for Facebook and Google;
* Inherited Resources on our controllers;
* SimpleForm for new and edit forms;
* WickedPDF for PDF generation;

##How it works
In some words, Carnival provides a managing infra-structure for your application. All the data related to Carnival will be located under the /admin namespace.


## Getting started

Carnival works with Rails 4.0 onwards. You can add it to your Gemfile with:

```ruby
gem 'carnival'
```

Run `bundle install`


Execute `rails generate carnival:install` after you install Carnival to copy migrations and generate the initializer.

If you already have created your database with `rake db:create`, just run `rake db:migrate` to execute the Carnival migrations.


## Usage

### Model

```ruby

module Admin
  class Company < ActiveRecord::Base

    include Carnival::ModelHelper
    self.table_name = "companies"

  end
end

```

### Controller

```ruby

module Admin
  class CompaniesController < Carnival::BaseAdminController
    layout "carnival/admin"

    def permitted_params
      params.permit(admin_company: [:name])
    end
  end
end

```

### Presenter

```ruby

module Admin
  class CompanyPresenter < Carnival::BaseAdminPresenter
    field :id,
          :actions => [:index, :show], :sortable => false,
          :searchable => true,
          :advanced_search => {:operator => :equal}
    field :name,
          :actions => [:index, :new, :edit, :show],
          :searchable => true,
          :advanced_search => {:operator => :like}
    field :created_at, :actions => [:index, :show]

    action :show
    action :edit
    action :destroy
    action :new

  end
end
```

### Dependent Selects

This feature is used when you have dependent selects like Country, State and City to fill an Address or a Location, because Cities Select only can be filled withe the oprions when a State is selected, and the State when de Country is selected, to implement this kind of behavior in a form, just use the option :depends_on in the dependent field with the symbol of the dependency, follows an example bellow:

```ruby
field :country,
      :actions => [:index, :csv, :pdf, :new, :edit, :show]
field :state,
      :actions => [:index, :csv, :pdf, :new, :edit, :show]
      :depends_on => :country
field :city,
      :actions => [:index, :csv, :pdf, :new, :edit, :show]
      :depends_on => :state
```


## Menu

The menu of the carnival can be configured in the carnival\_initializers.rb file

Ex:

``` ruby
config.menu =
{
  :city => {
    :label => "city",
    :class => "",
    :link => 'admin_cities_path', #You can use the route name as String to define the link
    :subs => [
      {
      :label => "custom_city",
      :class => "",
      :link => 'admin/custom/cities', #Or you can use the full path
      },
      {
        :label => 'google',
        :class => "",
        :link => 'http://www.google.com'
      }
    ]
  },
  ...
}

```

## Configurations

### Custom AdminUser

If you want to have your own AdminUser class or need to add methods to that class, you need to do the following steps:

- Configure the ar\_admin\_user\_class in the carnival\_initializers.rb file

``` ruby
Carnival::Config.ar_admin_user_class = MyAdminClass
```

- Your class need to inheritance from ActiveRecord::Base

### Custom Root Action

``` ruby
Carnival::Config.root_action = 'my_controller#my_action'
```

## Custom Translations

You can add custom translations for the actions [:new, :show, :edit, :destroy]

```ruby
  company:
    new: Create New company
    show: Show company
```


##TODO
* create has many association input data

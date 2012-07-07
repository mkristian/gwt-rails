Feature: Setup GWT on a rails application

  # Scenario: no optimistic, no place, no serializer
  #   # Given application and setup GWT with "--timestamps --gin"
  #   # Then gwt compile succeeds

  #   Given application and setup GWT with "--skip-timestamps --gin --skip-serializer"
  #   When scaffold a resource "store" with "--store"
  #   And scaffold a resource "cache" with "--cache"
  #   And scaffold a resource "nocache" with "--skip-cache"
  #   Then gwt compile succeeds

  #   # Given application and setup GWT with "--skip-timestamps --skip-gin"
  #   # Then gwt compile succeeds

  #   Given application and setup GWT with "--timestamps --skip-gin --skip-serializer"
  #   When scaffold a resource "store" with "--store"
  #   And scaffold a resource "cache" with "--cache"
  #   And scaffold a resource "nocache" with "--skip-cache"
  #   Then gwt compile succeeds

  # Scenario: with optimistic, no place, no serializer
  #   Given application and setup GWT with "--optimistic --gin --skip-serializer"
  #   When scaffold a resource "store" with "--store"
  #   And scaffold a resource "cache" with "--cache"
  #   And scaffold a resource "nocache" with "--skip-cache"
  #   Then gwt compile succeeds

  #   # Given application and setup GWT with "--optimistic --skip-gin"
  #   # Then gwt compile succeeds

  Scenario: no optimistic, with place, with serializer
    # Given application and setup GWT with "--timestamps --place"
    # Then gwt compile succeeds

    Given application and setup GWT with "--skip-timestamps --place --serializer"
#    When scaffold a resource "store" with "--store"
#    And scaffold a resource "cache" with "--cache"
    And scaffold a resource "nocache" with "--skip-cache"
    Then gwt compile succeeds

  Scenario: with optimistic, with place, with serializer
    Given application and setup GWT with "--optimistic --place --serializer"
    When scaffold a resource "store" with "--store"
    And scaffold a resource "cache" with "--cache"
    And scaffold a resource "nocache" with "--skip-cache"
    # And execute "rails generate scaffold store color:string --store"
    # And execute "rails generate scaffold store_read_only color:string --store --read_only"
    # And execute "rails generate scaffold store_singleton color:string --store --singleton"
    # And execute "rails generate scaffold store_singleton_read_only color:string --store --singleton --read_only"
    # And execute "rails generate scaffold cache color:string --cache"
    # And execute "rails generate scaffold cache_read_only color:string --cache --read_only"
    # And execute "rails generate scaffold cache_singleton color:string --cache --singleton"
    # And execute "rails generate scaffold cache_singleton_read_only color:string --cache --singleton --read_only"
    # And execute "rails generate scaffold skip_cache color:string --skip-cache"
    # And execute "rails generate scaffold skip_cache_readonly color:string --skip-cache --read-only"
    # And execute "rails generate scaffold skip_cache_singleton color:string --skip-cache --singleton"
    # And execute "rails generate scaffold skip_cache_singleton_read_only color:string --skip-cache --singleton --read_only"
    Then gwt compile succeeds


  Scenario: with optimistic, with place, with serializer. with menu
    Given application and setup GWT with "--optimistic --serializer --menu"
    When scaffold a resource "car"
    Then gwt compile succeeds

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

  # Scenario: no optimistic, with place, with serializer
  #   # Given application and setup GWT with "--timestamps --place"
  #   # Then gwt compile succeeds

  #   Given application and setup GWT with "--skip-timestamps --place --serializer"
  #   When scaffold a resource "store" with "--store"
  #   And scaffold a resource "cache" with "--cache"
  #   And scaffold a resource "nocache" with "--skip-cache"
  #   Then gwt compile succeeds

  # Scenario: with optimistic, with place, with serializer
  #   Given application and setup GWT with "--optimistic --place --serializer"
  #   When scaffold a resource "store" with "--store"
  #   And scaffold a resource "cache" with "--cache"
  #   And scaffold a resource "nocache" with "--skip-cache"
  #   Then gwt compile succeeds

  Scenario: with optimistic, with place, with serializer, with menu
    Given application and setup GWT with "--optimistic --serializer --menu"
    When scaffold a resource "car"
    Then gwt compile succeeds

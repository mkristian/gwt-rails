Feature: Setup rails API server

  Scenario: with optimistic, with serializer
    Given application setup with "--optimistic --serializer"
    When scaffold a resource "car"
    And execute "rake db:migrate db:seed"
    Then "rake conflict serialize" succeeds.

  # Scenario: with optimistic, no serializer
  #   Given application setup with "--optimistic --skip-serializer"
  #   When scaffold a resource "car"
  #   And execute "rake db:migrate db:seed"
  #   Then "rake timestamps" succeeds.

  Scenario: with timestamps, with serializer
    Given application setup with "--timestamps --serializer"
    When scaffold a resource "car"
    And execute "rake db:migrate db:seed"
    Then "rake timestamps serialize" succeeds.

  # Scenario: with timestamps, no serializer
  #   Given application setup with "--timestamps --skip-serializer"
  #   When scaffold a resource "car"
  #   And execute "rake db:migrate db:seed"
  #   Then "rake timestamps" succeeds.

  Scenario: no timestamps, with serializer
    Given application setup with "--skip-timestamps --serializer"
    When scaffold a resource "car"
    And execute "rake db:migrate db:seed"
    Then "rake ids" succeeds.

  # Scenario: no timestamps, no serializer
  #   Given application setup with "--skip-timestamps --skip-serializer"
  #   When scaffold a resource "car"
  #   And execute "rake db:migrate db:seed"
  #   Then "rake ids" succeeds.

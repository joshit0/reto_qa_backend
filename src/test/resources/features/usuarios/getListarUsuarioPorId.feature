@getListarUsuarioPorId
Feature: Listar usuarios

  Background:
    * def factory = Java.type('com.coforge.qa.helpers.UserDataFactory')
    * def schema = read('classpath:schemas/getListarUsuarioPorId.json')
    Given url baseUrl

  @smoke
  Scenario: Filtrar usuario por id
    * def dataUsuario = factory.generarDataUsuario()
    * def usuarioCreado = call read('classpath:features/common/crearUsuario.feature') { requestBody: '#(dataUsuario)' }
    * set dataUsuario._id = usuarioCreado.response._id
    Given path 'usuarios', dataUsuario._id
    When method get
    Then status 200
    And match response == schema["200"]
    And match response == dataUsuario

  Scenario: Error filtrar usuario con id inexistente
    * def id = factory.randomAlphanumeric(16)
    * set schema["400"].message = '#string'
    Given path 'usuarios', id
    When method get
    Then status 400
    And match response == schema["400"]
    And match response.message == "Usuário não encontrado"

  Scenario Outline: Error filtrar usuario con id formato invalido
    * set schema["400"].id = '#string'
    Given path 'usuarios', '<id>'
    When method get
    Then status 400
    And match response == schema["400"]
    And match response.id == '<mensaje>'
    Examples:
      | id                | mensaje                                            |
      | 1                 | id deve ter exatamente 16 caracteres alfanuméricos |
      | 123456789012345   | id deve ter exatamente 16 caracteres alfanuméricos |
      | 12345678901234567 | id deve ter exatamente 16 caracteres alfanuméricos |
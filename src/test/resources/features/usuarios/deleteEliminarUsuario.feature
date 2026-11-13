@deleteEliminarUsuario
Feature: Eliminar usuarios

  Background:
    * def factory = Java.type('com.coforge.qa.helpers.UserDataFactory')
    * def schema = read('classpath:schemas/deleteEliminarUsuario.json')
    Given url baseUrl

  @smoke
  Scenario: Eliminar un usuario existente
    * def dataUsuario = factory.generarDataUsuario()
    * def usuarioCreado = call read('classpath:features/common/crearUsuario.feature') { requestBody: '#(dataUsuario)' }
    * set id = usuarioCreado.response._id
    Given path 'usuarios', id
    When method delete
    Then status 200
    And match response == { message: 'Registro excluído com sucesso' }

  Scenario: Informar que no se elimino un usuario con id inexistente
    * def id = factory.randomAlphanumeric(16)
    Given path 'usuarios', id
    When method delete
    Then status 200
    And match response == schema["200"]
    And match response.message == 'Nenhum registro excluído'

  Scenario Outline: Informar que no se elimino un usuario con id formato invalido
    Given path 'usuarios', '<id>'
    When method delete
    Then status 200
    And match response == schema["200"]
    And match response.message == '<mensaje>'
    Examples:
      | id | mensaje                  |
      | 1  | Nenhum registro excluído |

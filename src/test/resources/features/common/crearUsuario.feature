@ignore
Feature: Helper para crear usuarios de prueba

  Scenario: Crear un usuario valido
    Given url baseUrl
    And path 'usuarios'
    And request requestBody
    When method post
    Then status 201
    And match response == { message: 'Cadastro realizado com sucesso', _id: '#regex ^[A-Za-z0-9]{16}$' }
    * def id = response._id
    * def usuarioCreado = response

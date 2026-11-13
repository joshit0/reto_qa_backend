@getListarUsuarios
Feature: Listar usuarios

  Background:
    * def factory = Java.type('com.coforge.qa.helpers.UserDataFactory')
    * def schema = read('classpath:schemas/getListarUsuarios.json')
    Given url baseUrl
    And path 'usuarios'

  @smoke
  Scenario: Listar todos los usuarios registrados
    When method get
    Then status 200
    And match response == schema["200"]
    And match response.quantidade == response.usuarios.length

  @smoke
  Scenario Outline: Filtrar usuarios por campo '<campo>'
    * def dataUsuario = factory.generarDataUsuario()
    * def usuarioCreado = call read('classpath:features/common/crearUsuario.feature') { requestBody: '#(dataUsuario)' }
    * set dataUsuario._id = usuarioCreado.response._id
    Given param <campo> = dataUsuario.<campo>
    When method get
    Then status 200
    And match response == schema["200"]
    And match response.quantidade == 1
    And match response.usuarios[0] == dataUsuario
    Examples:
      | campo    |
      | _id      |
      | nome     |
      | email    |
      | password |

  Scenario Outline: Filtrar usuarios por campo 'administrador' valor <valor>
    * def dataUsuario = factory.generarDataUsuario()
    * def usuarioCreado = call read('classpath:features/common/crearUsuario.feature') { requestBody: '#(dataUsuario)' }
    * set dataUsuario._id = usuarioCreado.response._id
    And param <campo> = <valor>
    When method get
    Then status 200
    And match response == schema["200"]
    And match response.quantidade == response.usuarios.length
    Examples:
      | campo         | valor   |
      | administrador | 'true'  |
      | administrador | 'false' |

  Scenario: No encontrar usuarios con un email inexistente
    * def dataUsuario = factory.generarDataUsuario()
    Given param email = dataUsuario.email
    When method get
    Then status 200
    And match response == schema["200"]
    And match response.quantidade == 0
    And match response.usuarios ==  []

  Scenario: Rechazar un filtro con email invalido
    And param email = 'correo-invalido'
    When method get
    Then status 400
    And match response == { email: 'email deve ser um email válido' }

  Scenario Outline: Error filtrar usuarios por campo '<campo>' con valor <valor>
    * set schema["400"].<campo> = "<mensaje>"
    Given param <campo> = <valor>
    When method get
    Then status 400
    And match response == schema["400"]
    Examples:
      | campo         | valor                 | mensaje                                  |
      | email         | 'abcde'               | email deve ser um email válido           |
      | email         | 'abcde@'              | email deve ser um email válido           |
      | email         | 'abcde@.com'          | email deve ser um email válido           |
      | email         | 'abcde@gmail.com.'    | email deve ser um email válido           |
      | email         | '@gmail.com'          | email deve ser um email válido           |
      | email         | 'abcde..@gmail.com'   | email deve ser um email válido           |
      | email         | 'abcde@gmail'         | email deve ser um email válido           |
      | email         | 'abcde@gmail..com'    | email deve ser um email válido           |
      | email         | 'abcde@ gmail.com'    | email deve ser um email válido           |
      | email         | 'abcde @gmail.com'    | email deve ser um email válido           |
      | email         | 'abcde@@gmail.com'    | email deve ser um email válido           |
      | email         | 'abcde@gmail,com'     | email deve ser um email válido           |
      | email         | '.abcde@gmail.com'    | email deve ser um email válido           |
      | email         | 'abcde.@gmail.com'    | email deve ser um email válido           |
      | email         | 'abcde@gmail.com..pe' | email deve ser um email válido           |
      | email         | 'abcde@-gmail.com'    | email deve ser um email válido           |
      | email         | ' '                   | email deve ser uma string                |
      | administrador | 1                     | administrador deve ser 'true' ou 'false' |
      | administrador | 'a'                   | administrador deve ser 'true' ou 'false' |
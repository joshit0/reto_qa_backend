@postRegistrarUsuario
Feature: Registrar usuarios

  Background:
    * def factory = Java.type('com.coforge.qa.helpers.UserDataFactory')
    * def schema = read('classpath:schemas/postRegistrarUsuario.json')
    Given url baseUrl
    And path 'usuarios'

  @smoke
  Scenario: Registrar usuario administrador con datos validos
    * def requestBody = factory.generarDataUsuario()
    Given request requestBody
    When method post
    Then status 201
    And match response == schema['201']
    And match response.message == 'Cadastro realizado com sucesso'

  Scenario Outline: Registrar usuario campo '<campo>' con valor <valor>
    * def requestBody = factory.generarDataUsuario()
    Given request requestBody
    When method post
    Then status 201
    And match response == schema["201"]
    And match response.message == 'Cadastro realizado com sucesso'
    Examples:
      | campo         | valor               |
      | nome          | 'José Quispe'       |
      | nome          | "O'Connor"          |
      | nome          | 'Ana-María'         |
      | email         | 'abcde@gmail.com'   |
      | email         | 'abc.de@gmail.com'  |
      | email         | 'abc+123@gmail.com' |
      | password      | 'Abc123!@#'         |
      | password      | 'P@ssw0rd_2026'     |
      | administrador | 'true'              |
      | administrador | 'false'             |

  Scenario: Error registro de usuario con email duplicado
    * def requestBody = factory.generarDataUsuario()
    * def usuarioCreado = call read('classpath:features/common/crearUsuario.feature')
    * set schema["400"].message = '#string'
    Given request requestBody
    When method post
    Then status 400
    And match response == schema["400"]
    And match response.message == 'Este email já está sendo usado'

  Scenario Outline: Error registro cuando falta el campo obligatorio '<campo>'
    * def requestBody = factory.generarDataUsuarioSinCampo('<campo>')
    * set schema["400"].<campo> = '#string'
    Given request requestBody
    When method post
    Then status 400
    And match response == schema["400"]
    And match response.<campo> == '<mensaje>'
    Examples:
      | campo         | mensaje                     |
      | nome          | nome é obrigatório          |
      | email         | email é obrigatório         |
      | password      | password é obrigatório      |
      | administrador | administrador é obrigatório |

  Scenario Outline: Error registro usuario cuando se envie campo '<campo>' con valor <valor>
    * def requestBody = factory.generarDataUsuario()
    * set requestBody.<campo> = <valor>
    * set schema["400"].<campo> = '#string'
    Given request requestBody
    When method post
    Then status 400
    And match response == schema["400"]
    And match response.<campo> == "<mensaje>"
    Examples:
      | campo         | valor                 | mensaje                                  |
      | nome          | 1                     | nome deve ser uma string                 |
      | nome          | true                  | nome deve ser uma string                 |
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
      | email         | ' '                   | email deve ser um email válido           |
      | password      | 1                     | password deve ser uma string             |
      | password      | true                  | password deve ser uma string             |
      | administrador | 1                     | administrador deve ser 'true' ou 'false' |
      | administrador | 'a'                   | administrador deve ser 'true' ou 'false' |
      | administrador | true                  | administrador deve ser 'true' ou 'false' |
      | administrador | false                 | administrador deve ser 'true' ou 'false' |




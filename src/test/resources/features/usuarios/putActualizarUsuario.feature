@putActualizarUsuario
Feature: Actualizar usuarios

  Background:
    * def factory = Java.type('com.coforge.qa.helpers.UserDataFactory')
    * def schema = read('classpath:schemas/putActualizarUsuario.json')
    Given url baseUrl

  @smoke
  Scenario: Actualizar un usuario existente
    * def dataUsuario = factory.generarDataUsuario()
    * def usuarioCreado = call read('classpath:features/common/crearUsuario.feature') { requestBody: '#(dataUsuario)' }
    * set dataUsuario._id = usuarioCreado.response._id
    * def dataUsuarioActualizado = factory.generarDataUsuario()
    Given path 'usuarios', dataUsuario._id
    And request dataUsuarioActualizado
    When method put
    Then status 200
    And match response == schema["200"]
    And match response.message == 'Registro alterado com sucesso'


  Scenario: Crear un usuario al actualizar un identificador inexistente
    * def idInexistente = factory.randomAlphanumeric(16)
    * def dataUsuario = factory.generarDataUsuario()
    Given path 'usuarios', idInexistente
    And request dataUsuario
    When method put
    Then status 201
    And match response == schema['201']
    And match response.message == 'Cadastro realizado com sucesso'

  Scenario: Error actualizar con el email de otro usuario
    * def dataUsuario01 = factory.generarDataUsuario()
    * def usuarioCreado01 = call read('classpath:features/common/crearUsuario.feature') { requestBody: '#(dataUsuario01)' }
    * def dataUsuario02 = factory.generarDataUsuario()
    * def usuarioCreado02 = call read('classpath:features/common/crearUsuario.feature') { requestBody: '#(dataUsuario02)' }
    * set dataUsuario02._id = usuarioCreado02.response._id
    * set schema["400"].message = '#string'
    Given url baseUrl
    And path 'usuarios', dataUsuario02._id
    And request dataUsuario01
    When method put
    Then status 400
    And match response == schema["400"]
    And match response.message == 'Este email já está sendo usado'

  Scenario Outline: Error actualizar cuando falta un campo obligatorio
    * def requestBody = factory.generarDataUsuario()
    * def usuarioCreado = call read('classpath:features/common/crearUsuario.feature')
    * set id = usuarioCreado.response._id
    * def requestInvalido = factory.generarDataUsuarioSinCampo('<campo>')
    * set schema["400"].<campo> = '#string'
    Given path 'usuarios', id
    And request requestInvalido
    When method put
    Then status 400
    And match response == schema["400"]
    And match response.<campo> == '<mensaje>'
    Examples:
      | campo         | mensaje                     |
      | nome          | nome é obrigatório          |
      | email         | email é obrigatório         |
      | password      | password é obrigatório      |
      | administrador | administrador é obrigatório |

  Scenario Outline: Error actualizacion cuando se envie campo '<campo>' con valor <valor>
    * def requestBody = factory.generarDataUsuario()
    * def usuarioCreado = call read('classpath:features/common/crearUsuario.feature')
    * set id = usuarioCreado.response._id
    * set requestBody.<campo> = <valor>
    * print requestBody
    * set schema["400"].<campo> = '#string'
    Given path 'usuarios', id
    And request requestBody
    When method put
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


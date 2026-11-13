# Automatizacion API de Usuarios - ServeRest + Karate DSL

Suite de pruebas automatizadas para la API de Usuarios de [ServeRest](https://serverest.dev/), desarrollada con **Karate DSL**, **Maven** y **JUnit 6**.

El proyecto cubre las operaciones CRUD del recurso `/usuarios`, casos positivos y negativos, validacion de esquemas JSON, generacion dinamica de datos de prueba y escenarios de eliminacion con verificacion posterior.

---

## Tecnologias

| Tecnologia | Version | Uso |
|---|---|---|
| Java | 21 | Plataforma de ejecucion |
| Karate DSL | 2.1.4 | Automatizacion de API |
| JUnit | 6.1.3 | Runner de ejecucion |
| Maven | 3.6.3+ | Gestion de dependencias y ciclo de vida |
| Logback | 1.6.5 | Registro de logs |

---

## Requisitos

- JDK 21 o superior.
- Maven 3.6.3 o superior.
- Conexion a Internet para descargar dependencias de Maven y acceder a la API objetivo.
- Variables de entorno `JAVA_HOME` configuradas (recomendado).

Verificar Java:

```powershell
java -version
```
---
## Instalación

```bash
git clone https://github.com/joshit0/reto_qa_frontend.git
cd reto_qa_frontend
npm install
npx playwright install chromium
```
---

## Estructura del proyecto

```text
prueba_backend/
├── pom.xml
├── .gitignore
├── README.md
├── API.postman_collection.json        # Coleccion base entregada
└── src/test/
    ├── java/com/coforge/qa/
    │   ├── helpers/UserDataFactory.java
    │   └── runner/UsuariosRunnerTest.java
    └── resources/
        ├── karate-config.js
        ├── logback-test.xml
        ├── features/
        │   ├── common/
        │   │   └── crearUsuario.feature
        │   └── usuarios/
        │       ├── deleteEliminarUsuario.feature
        │       ├── getListarUsuarioPorId.feature
        │       ├── getListarUsuarios.feature
        │       ├── postRegistrarUsuario.feature
        │       └── putActualizarUsuario.feature
        └── schemas/
            ├── deleteEliminarUsuario.json
            ├── getListarUsuarioPorId.json
            ├── getListarUsuarios.json
            ├── postRegistrarUsuario.json
            └── putActualizarUsuario.json
```

---

## Configuracion

La configuracion principal esta en `src/test/resources/karate-config.js`:

- `env`: ambiente de ejecucion. Por defecto `dev`.
- `baseUrl`: URL de la API. Se puede sobrescribir con `-DbaseUrl=...`.
- Ambientes predefinidos:
  - `dev`: `https://serverest.dev`
  - `qa`: `https://qa.serverest.dev` (URL de ejemplo)
  - `local`: `http://localhost:3000` (URL de ejemplo)
- `factory`: expone `UserDataFactory` a los features.
- Timeouts: conexion `15000 ms` y lectura `30000 ms`.
- Reintentos HTTP: `2` intentos con intervalo de `1000 ms`.
- Logs: peticiones y respuestas con formato legible para `dev`, `qa` y `local`.

> Las URLs de `qa` y `local` son ejemplos. Si no corresponden a un entorno disponible, usa `-DbaseUrl` para indicar la URL real.

### Precedencia de `baseUrl`

1. `-DbaseUrl=...`
2. `baseUrl` definida para el ambiente seleccionado.
3. `https://serverest.dev`

### Comandos por ambiente

Windows PowerShell (usa `--%` para que `-Dkarate.options` llegue intacto a Maven):

```powershell
# Desarrollo
mvn test --% -Dkarate.env=dev

# QA con URL real
mvn test --% -Dkarate.env=qa 

# Local
mvn test --% -Dkarate.env=local 
```

---

## Ejecucion

### Ejecutar toda la suite

Windows PowerShell:

```powershell
mvn clean test --% -Dkarate.env=dev
```

### Ejecutar solo escenarios smoke

```powershell
mvn test --% -Dkarate.options="--tags @smoke" -Dkarate.env=dev
```

### Ejecutar un feature especifico por tag

```powershell
mvn test --% -Dkarate.options="--tags @putActualizarUsuario" -Dkarate.env=dev
```

Tags disponibles por feature: `@getListarUsuarios`, `@postRegistrarUsuario`, `@getListarUsuarioPorId`, `@putActualizarUsuario`, `@deleteEliminarUsuario`.

### Ejecutar un feature especifico por ruta

```powershell
mvn test --% -Dkarate.path=classpath:features/usuarios/putActualizarUsuario.feature -Dkarate.env=dev
```

### Cambiar el numero de hilos

```powershell
mvn test --% -Dkarate.options="--tags @smoke" -Dkarate.env=dev -Dkarate.threads=8
```

### Ejecutar el runner directamente

```powershell
mvn test --% -Dtest=UsuariosRunnerTest -Dkarate.env=dev
```

### Parametros disponibles

| Parametro | Valor por defecto | Descripcion |
|---|---|---|
| `karate.env` | `dev` | Ambiente de ejecucion |
| `baseUrl` | URL del ambiente | Sobrescribe la URL base |
| `karate.options` | - | Opciones CLI de Karate, por ejemplo `--tags @smoke` |
| `karate.tags` | `~@ignore` | Filtro de tags del runner (alternativa a `karate.options`) |
| `karate.path` | `src/test/resources/features` | Ruta de features |
| `karate.threads` | `5` | Numero de hilos paralelos |

> En Windows PowerShell, `--%` detiene el parseo y permite enviar `-Dkarate.options="--tags @..."` sin alteraciones.
>
> El helper `features/common/crearUsuario.feature` esta marcado con `@ignore`, por lo que no se ejecuta como escenario independiente. Los escenarios principales estan marcados con `@smoke`.

---

## Cobertura de pruebas

| Feature | Endpoint | Escenarios |
|---|---|---:|
| `getListarUsuarios.feature` | `GET /usuarios` | 28 |
| `postRegistrarUsuario.feature` | `POST /usuarios` | 41 |
| `getListarUsuarioPorId.feature` | `GET /usuarios/{_id}` | 5 |
| `putActualizarUsuario.feature` | `PUT /usuarios/{_id}` | 32 |
| `deleteEliminarUsuario.feature` | `DELETE /usuarios/{_id}` | 3 |
| **Total ejecutable** | | **109** |

Ademas existe `crearUsuario.feature` como helper reutilizable, excluido de la ejecucion mediante `@ignore`.

Casos cubiertos:

- `GET /usuarios`: listado completo, esquema, consistencia de cantidad, filtros por `_id`, `nome`, `email`, `password` y `administrador`, email inexistente y filtros invalidos.
- `POST /usuarios`: registro de administrador y usuario comun, validacion de campos y formatos, email duplicado y campos obligatorios faltantes.
- `GET /usuarios/{_id}`: busqueda de usuario existente, ID inexistente e IDs con formato invalido.
- `PUT /usuarios/{_id}`: actualizacion exitosa con verificacion posterior, ID inexistente que genera un nuevo usuario, email duplicado, campos faltantes y valores invalidos.
- `DELETE /usuarios/{_id}`: eliminacion exitosa, ID inexistente e ID con formato invalido.

---

## Estrategia de automatizacion

### Enfoque general

1. **Un feature por endpoint** para mantener trazabilidad entre criterios de aceptacion y pruebas.
2. **Background** en cada feature para cargar el factory, el esquema y la `baseUrl`.
3. **Feature helper reutilizable** (`crearUsuario.feature`) para evitar duplicar el paso de creacion de usuarios de apoyo.
4. **Runner unico en JUnit 6** con ejecucion paralela, reportes HTML, Cucumber JSON y JUnit XML.
5. **Datos dinamicos** generados en cada ejecucion para evitar colisiones con la base compartida de ServeRest.
6. **Validacion con esquemas JSON** leidos desde `classpath:schemas`.

### Enfoque API First

Bajo API First, el contrato es la fuente de verdad. Con un contrato que solo define nombres de campos y tipo `string`, la automatizacion puede iniciarse validando endpoints, metodos, codigos HTTP, campos requeridos, tipos y estructura de respuesta.

Las validaciones de formato, longitud, expresiones regulares y mensajes exactos no se consideran requisitos de contrato hasta que esten declarados. En esta suite se tratan como supuestos o validaciones de implementacion; para convertirlas en pruebas de contrato, el contrato debe especificar `format`, `minLength`, `maxLength`, `pattern`, `required`, ejemplos y codigos/mensajes de error.

| Cubierto por el contrato actual | Fuera del contrato actual |
|---|---|
| Endpoints y metodos | Formato de email |
| Codigos HTTP | Longitud de password |
| Nombres de campos y tipo `string` | Regex de `_id` |
| Estructura de respuesta | Mensajes exactos de error |

### Patrones utilizados

- **Factory**: `UserDataFactory` centraliza la creacion de datos validos.
- **Feature per Endpoint**: cada operacion CRUD tiene su propio archivo `.feature`.
- **Helper Feature**: `crearUsuario.feature` encapsula la creacion de un usuario valido.
- **Schema-driven validation**: los esquemas JSON se comparan con `match` y `match each`.
- **Data-driven testing**: `Scenario Outline` + `Examples` para validar campos obligatorios, formatos y tipos invalidos.
- **Tagging**: `@smoke` para los escenarios principales y `@ignore` para el helper.

### Validacion de respuestas

- Codigos HTTP esperados en cada operacion.
- Mensajes de negocio exactos (`Cadastro realizado com sucesso`, `Registro alterado com sucesso`, `Usuário não encontrado`, etc.).
- Esquemas JSON con marcadores de Karate (`#string`, `#number`, `#array`, `#regex`).
- Verificacion de persistencia: las operaciones `POST` y `PUT` se comprueban con un `GET` posterior cuando aplica.
- Verificacion de eliminacion: tras un `DELETE` exitoso se valida que el `GET` devuelva `400`.

### Limpieza de datos

Actualmente no hay un hook global `afterScenario` que elimine todos los usuarios creados. Los escenarios de `DELETE` validan la eliminacion, pero los usuarios creados en otros escenarios pueden permanecer en la base compartida de ServeRest. Si se requiere una limpieza global, se puede implementar en `karate-config.js` con `afterScenario` o `afterFeature`, cuidando la ejecucion paralela y la base compartida.

---

## Manejo de datos de prueba

Los datos se generan con `UserDataFactory`:

- Emails unicos basados en timestamp, secuencia y sufijo aleatorio.
- Nombres y passwords unicos.
- Payloads especificos para casos negativos mediante `generarDataUsuarioSinCampo(campo)`.
- IDs de 16 caracteres alfanumericos para simular recursos inexistentes con `randomAlphanumeric(16)`.

Esto evita depender de usuarios fijos de la API publica y permite ejecutar la suite repetidamente sin colisiones.

---

## Reportes

Al finalizar la ejecucion se generan:

- Reporte HTML de Karate: `target/karate-reports/karate-summary.html`
- Reportes de Surefire: `target/surefire-reports/`
- Resultados Cucumber JSON: `target/karate-reports/`
- Resultados JUnit XML: `target/karate-reports/`

Para abrir el reporte HTML en Windows:

```powershell
Start-Process target\karate-reports\karate-summary.html
```

---

## Notas sobre la API publica

- La instancia publica de ServeRest comparte base de datos entre todos los usuarios. Por eso la suite genera datos unicos.
- Durante la validacion de esta suite, las rutas de `/usuarios` no exigieron token de autenticacion. Si la API cambia y empieza a exigirlo, se puede agregar un feature de login y configurar el token en `karate-config.js`.
- La suite tampoco valida headers de seguridad en las respuestas (por ejemplo, `Strict-Transport-Security`, `Content-Security-Policy`, `X-Frame-Options`); ese aspecto queda fuera del alcance actual.
- El contrato compartido solo definia nombres de campos y tipo `string`, sin formatos, longitudes ni expresiones regulares. Bajo API First, esas validaciones se consideran supuestos o pruebas de implementacion hasta que el contrato las declare; para formalizarlas, deben incorporarse al contrato.
- `DELETE` sobre un ID inexistente devuelve `200` con el mensaje `Nenhum registro excluído`.

---


## Comandos rapidos

```powershell
# Suite completa en dev
mvn clean test --% -Dkarate.env=dev

# Solo smoke
mvn test --% -Dkarate.options="--tags @smoke" -Dkarate.env=dev

# Un feature por tag
mvn test --% -Dkarate.options="--tags @putActualizarUsuario" -Dkarate.env=dev

# Un feature por ruta
mvn test --% -Dkarate.path=classpath:features/usuarios/putActualizarUsuario.feature -Dkarate.env=dev

```

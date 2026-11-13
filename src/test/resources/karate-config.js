function fn() {
  var env = karate.env || "dev";
  var envs = {
    dev: { baseUrl: "https://serverest.dev" },
    qa: { baseUrl: "https://qa.serverest.dev" }, // baseUrl de ejemplo
    local: { baseUrl: "http://localhost:3000" }, // baseUrl de ejemplo
  };

  var config = envs[env] || envs.dev;
  config.env = env;
  config.baseUrl = karate.properties["baseUrl"] || config.baseUrl;
  config.factory = Java.type("com.coforge.qa.helpers.UserDataFactory");

  karate.configure("connectTimeout", 15000);
  karate.configure("readTimeout", 30000);
  karate.configure("retry", { count: 2, interval: 1000 });
  karate.configure("logPrettyRequest", env !== "prod");
  karate.configure("logPrettyResponse", env !== "prod");

  return config;
}
